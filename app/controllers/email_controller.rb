
class EmailController < ApplicationController
  before_action :authenticate_user!

  # Время жизни токена подтверждения в Redis
  TOKEN_EXPIRY = 2.hours

  def confirmation
    # Просто отображает форму ввода нового email
  end

  def change_status
    new_email = params[:email]&.strip

    # Валидация: email не должен быть пустым
    if new_email.blank?
      flash.now[:alert] = "Адрес электронной почты не может быть пустым."
      return render :confirmation, status: :unprocessable_entity
    end

    # Валидация формата email с помощью стандартной библиотеки URI
    unless URI::MailTo::EMAIL_REGEXP.match?(new_email)
      flash.now[:alert] = "Пожалуйста, введите корректный адрес электронной почты в формате 'имя@домен.com'."
      return render :confirmation, status: :unprocessable_entity
    end

    # Генерация криптографически стойкого токена для безопасности операции
    token = generate_secure_token

    # Сохраняем запрос на смену email в Redis с автоудалением (TTL)
    # Использование Redis вместо БД позволяет избежать мусорных данных и автоочистки устаревших токенов
    with_redis do |r|
      r.setex(
        "email_change:#{token}",
        TOKEN_EXPIRY.to_i,
        {
          user_id: current_user.id,
          new_email: new_email,
          created_at: Time.current.iso8601
        }.to_json
      )
    end

    # Отправляем письмо асинхронно (через ActiveJob), чтобы не блокировать ответ пользователю
    UserMailer.with(user: current_user, new_email: new_email, token: token)
              .email_change_confirmation
              .deliver_later

    redirect_to profile_path, notice: "Письмо с подтверждением отправлено на #{new_email}"
  rescue => e
    # Логируем технические ошибки, но пользователю показываем общее сообщение
    Rails.logger.error "Error in EmailController#change_status: #{e.class} #{e.message}"
    flash.now[:alert] = "Произошла ошибка. Попробуйте позже."
    render :confirmation, status: :internal_server_error
  end

  def confirm
    token = params[:token]

    # Проверка наличия токена в ссылке
    if token.blank?
      flash[:alert] = "Недействительная ссылка подтверждения"
      redirect_to profile_path and return
    end

    # Попытка получить данные из Redis (токен мог истечь)
    data = get_email_change_data(token)

    if data.blank?
      flash[:alert] = "Ссылка подтверждения недействительна или истекла"
      redirect_to profile_path and return
    end

    user = User.find_by(id: data["user_id"])

    if user.blank?
      flash[:alert] = "Пользователь не найден"
      redirect_to profile_path and return
    end

    # Проверка на уникальность: новый email не должен принадлежать другому пользователю
    if User.where.not(id: user.id).exists?(email: data["new_email"])
      flash[:alert] = "Этот адрес электронной почты уже используется другим пользователем"
      redirect_to profile_path and return
    end

    # Финальная смена email
    user.update!(email: data["new_email"])
    # Удаляем токен из Redis, чтобы ссылку нельзя было использовать повторно (One-time link)
    with_redis { |r| r.del("email_change:#{token}") }

    @email = data["new_email"]
    # Подтверждение email активирует двухфакторную аутентификацию
    current_user.update!(two_factor_enabled: true)

    render :success
  rescue => e
    Rails.logger.error "Error in EmailController#confirm: #{e.class} #{e.message}"
    flash[:alert] = "Произошла ошибка при подтверждении email: #{e.message}"
    redirect_to profile_path
  end

  private

  def generate_secure_token
    # Генерирует случайный URL-безопасный токен (32 байта = 256 бит)
    SecureRandom.urlsafe_base64(32)
  end

  def get_email_change_data(token)
    # Безопасно извлекает и парсит JSON из Redis
    with_redis do |r|
      data_json = r.get("email_change:#{token}")
      data_json.present? ? JSON.parse(data_json) : nil
    end
  rescue => e
    Rails.logger.error "Error retrieving email change data: #{e.class} #{e.message}"
    nil
  end

  def with_redis
    # Универсальный метод для работы с Redis.
    # Поддерживает как пул соединений (REDIS_POOL), так и одиночное подключение (REDIS_CLIENT).
    # Это позволяет гибко конфигурировать приложение в разных окружениях.
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
end
