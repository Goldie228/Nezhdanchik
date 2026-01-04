
class TwoFactorController < ApplicationController
  # Инициализируем пользователя, для которого выполняется 2FA
  before_action :set_target_user
  # Проверяем, что пользователь существует (авторизован или находится в процессе логина)
  before_action :authenticate
  # Убеждаемся, что пользователю действительно требуется двухфакторная аутентификация
  before_action :ensure_two_factor_needed

  # Время жизни OTP-кода (5 минут — баланс между безопасностью и удобством)
  OTP_EXPIRY = 5.minutes

  def show
    if otp_active?
      # Если код уже активен, просто показываем оставшееся время
      @time_left = ttl_seconds_for(otp_key)
    else
      # Генерируем и отправляем код, если текущего нет или он истек
      generate_and_send_otp
      @time_left = OTP_EXPIRY.to_i
    end
  rescue => e
    # Логируем ошибки Redis, чтобы приложение не упало, если редис недоступен
    Rails.logger.error "Redis error in TwoFactorController#show: #{e.class} #{e.message}"
    flash.now[:alert] = "Временная техническая неполадка. Пожалуйста, попробуйте позже."
    @time_left = 0
    render :show, status: :service_unavailable
  end

  def create
    submitted_code = params[:otp_code].to_s.strip

    # Валидация формата: код должен быть 6 цифр
    if submitted_code.blank? || submitted_code.length != 6
      flash.now[:alert] = "Введите 6-значный код"
      @time_left = ttl_seconds_for(otp_key)
      render :show, status: :unprocessable_entity and return
    end

    if otp_valid?(submitted_code)
      # Успешная проверка: завершаем вход, очищаем временные данные
      session[:two_factor_passed] = true
      session[:user_id] = session[:prep_user_id]
      session.delete(:prep_user_id)

      # Удаляем использованные данные из Redis (One-time use)
      with_redis do |r|
        r.del(otp_key)
        r.del(attempts_key)
        r.del(lock_key)
      end

      # Помечаем, что 2FA подтверждена (для фильтра email смены пароля и т.д.)
      @target_user.update!(two_factor_enabled: true)
      redirect_to root_path, notice: "Двухфакторная аутентификация пройдена"
    else
      # Ошибка: увеличиваем счетчик попыток
      attempts = increment_attempts

      if attempts_exceeded?(attempts)
        # Слишком много попыток: блокируем возможность запроса нового кода на 15 минут
        lock_otp_generation
        redirect_to two_factor_path, alert: "Слишком много попыток. Попробуйте позже."
      else
        # Показываем ошибку и оставшееся время жизни кода
        flash.now[:alert] = "Неверный код или срок действия истёк"
        @time_left = ttl_seconds_for(otp_key)
        render :show, status: :unprocessable_entity
      end
    end
  rescue => e
    Rails.logger.error "Redis error in TwoFactorController#create: #{e.class} #{e.message}"
    flash.now[:alert] = "Временная техническая неполадка. Пожалуйста, попробуйте позже."
    @time_left = 0
    render :show, status: :service_unavailable
  end

  def resend
    # Проверяем, можно ли отправить код повторно (нет блокировки и прошло время с последней отправки)
    if can_resend_otp?
      generate_and_send_otp
      redirect_to two_factor_path, notice: "Новый код отправлен"
    else
      # Если отправлять нельзя, сообщаем сколько ждать
      time_left = ttl_seconds_for(otp_key)
      redirect_to two_factor_path, alert: "Подождите #{time_left} секунд перед повторной отправкой"
    end
  rescue => e
    Rails.logger.error "Redis error in TwoFactorController#resend: #{e.class} #{e.message}"
    redirect_to two_factor_path, alert: "Временная техническая неполадка. Не удалось отправить код."
  end

  # JSON-эндпоинт для обновления таймера на фронте без перезагрузки страницы
  def verification
    render json: { time_left: ttl_seconds_for(otp_key) }
  rescue => e
    Rails.logger.error "Redis error in TwoFactorController#verification: #{e.class} #{e.message}"
    render json: { error: "Service unavailable" }, status: :service_unavailable
  end

  private

  # Генерация ключей Redis. Разделение ключей позволяет независимо управлять кодом, попытками и блокировкой.
  def otp_key
    "otp:#{@target_user.id}"
  end

  def attempts_key
    "otp_attempts:#{@target_user.id}"
  end

  def lock_key
    "otp_lock:#{@target_user.id}"
  end

  def otp_active?
    key_exists?(otp_key)
  end

  def can_resend_otp?
    # Разрешить повторную отправку, только если нет блокировки
    # И если код неактивен ИЛИ (активен, но прошло менее 60 сек с момента создания — антифлуд, или можно менять логику)
    # В текущей логике: если ключ существует и ttl > 60, то ждать.
    !key_exists?(lock_key) && (!otp_active? || ttl_seconds_for(otp_key) < 60)
  end

  def generate_and_send_otp
    # Генерируем случайный 6-значный код
    otp_code = sprintf("%06d", rand(100_000..999_999))

    with_redis do |r|
      # Сохраняем код в Redis с автоматическим удалением через OTP_EXPIRY
      r.setex(otp_key, OTP_EXPIRY.to_i, otp_code)
      # Сбрасываем счетчик неудачных попыток при генерации нового кода
      r.del(attempts_key)
    end

    # Обновляем поля в БД для аудита и истории
    @target_user.update!(
      email_otp_code: otp_code,
      email_otp_sent_at: Time.current,
      email_otp_attempts: 0
    )

    # Отправляем письмо в фоновом режиме, чтобы не задерживать ответ пользователю
    UserMailer.two_factor_authentication(@target_user, otp_code).deliver_later
  end

  def otp_valid?(submitted_code)
    # Сравнение значения в Redis с тем, что ввел пользователь
    with_redis { |r| r.get(otp_key) } == submitted_code
  end

  def increment_attempts
    with_redis do |r|
      # Инкремент счетчика попыток. Если ключа нет, создастся со значением 1.
      attempts = r.incr(attempts_key)
      # Устанавливаем время жизни счетчика (15 минут), чтобы он сам очистился
      r.expire(attempts_key, 15.minutes.to_i)
      @target_user.update!(email_otp_attempts: attempts)
      attempts
    end
  end

  def attempts_exceeded?(attempts = nil)
    attempts ||= with_redis { |r| r.get(attempts_key).to_i }
    # Лимит попыток — 5
    attempts >= 5
  end

  def lock_otp_generation
    # Блокируем генерацию новых кодов на 15 минут при превышении лимита попыток
    with_redis { |r| r.setex(lock_key, 15.minutes.to_i, true) }
  end

  def ensure_two_factor_needed
    # Проверяем, найден ли целевой пользователь
    @target_user.present?
  end

  def with_redis
    # Универсальный адаптер для работы с Redis: поддерживает пул соединений или прямой клиент
    if defined?(REDIS_POOL) && REDIS_POOL
      REDIS_POOL.with { |conn| yield conn }
    elsif defined?(REDIS_CLIENT) && REDIS_CLIENT
      yield REDIS_CLIENT
    else
      raise "Redis client not configured"
    end
  rescue => e
    Rails.logger.error "Redis access error: #{e.class} #{e.message}"
    raise
  end

  def ttl_seconds_for(key)
    # Возвращает оставшееся время жизни ключа в секундах (для таймера на UI)
    with_redis do |r|
      t = r.ttl(key).to_i
      t > 0 ? t : 0
    end
  rescue
    0
  end

  def key_exists?(key)
    with_redis { |r| r.exists?(key) }
  rescue
    false
  end

  def authenticate
    # Убеждаемся, что пользователь идентифицирован (найден по сессии или prep_user_id)
    @target_user.present?
  end

  def set_target_user
    # Приоритет за текущим залогиненным пользователем
    if current_user.present?
      @target_user = current_user
      return
    end

    # Если пользователь еще не залогинен, берем из временной сессии (после ввода пароля)
    @target_user = User.find_by(id: session[:prep_user_id])
  end
end
