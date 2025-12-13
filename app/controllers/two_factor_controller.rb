class TwoFactorController < ApplicationController
  before_action :set_target_user
  before_action :authenticate
  before_action :ensure_two_factor_needed

  OTP_EXPIRY = 5.minutes

  def show
    if otp_active?
      @time_left = ttl_seconds_for(otp_key)
    else
      generate_and_send_otp
      @time_left = OTP_EXPIRY.to_i
    end
  rescue => e
    Rails.logger.error "Redis error in TwoFactorController#show: #{e.class} #{e.message}"
    flash.now[:alert] = "Временная техническая неполадка. Пожалуйста, попробуйте позже."
    @time_left = 0
    render :show, status: :service_unavailable
  end

  def create
    submitted_code = params[:otp_code].to_s.strip

    if submitted_code.blank? || submitted_code.length != 6
      flash.now[:alert] = "Введите 6-значный код"
      @time_left = ttl_seconds_for(otp_key)
      render :show, status: :unprocessable_entity and return
    end

    if otp_valid?(submitted_code)
      session[:two_factor_passed] = true
      session[:user_id] = session[:prep_user_id]
      session.delete(:prep_user_id)

      with_redis do |r|
        r.del(otp_key)
        r.del(attempts_key)
        r.del(lock_key)
      end

      @target_user.update!(two_factor_enabled: true)
      redirect_to root_path, notice: "Двухфакторная аутентификация пройдена"
    else
      attempts = increment_attempts

      if attempts_exceeded?(attempts)
        lock_otp_generation
        redirect_to two_factor_path, alert: "Слишком много попыток. Попробуйте позже."
      else
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
    if can_resend_otp?
      generate_and_send_otp
      redirect_to two_factor_path, notice: "Новый код отправлен"
    else
      time_left = ttl_seconds_for(otp_key)
      redirect_to two_factor_path, alert: "Подождите #{time_left} секунд перед повторной отправкой"
    end
  rescue => e
    Rails.logger.error "Redis error in TwoFactorController#resend: #{e.class} #{e.message}"
    redirect_to two_factor_path, alert: "Временная техническая неполадка. Не удалось отправить код."
  end

  def verification
    render json: { time_left: ttl_seconds_for(otp_key) }
  rescue => e
    Rails.logger.error "Redis error in TwoFactorController#verification: #{e.class} #{e.message}"
    render json: { error: "Service unavailable" }, status: :service_unavailable
  end

  private

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
    !key_exists?(lock_key) && (!otp_active? || ttl_seconds_for(otp_key) < 60)
  end

  def generate_and_send_otp
    otp_code = sprintf("%06d", rand(100000..999999))

    with_redis do |r|
      r.setex(otp_key, OTP_EXPIRY.to_i, otp_code)
      r.del(attempts_key)
    end

    @target_user.update!(
      email_otp_code: otp_code,
      email_otp_sent_at: Time.current,
      email_otp_attempts: 0
    )

    UserMailer.two_factor_authentication(@target_user, otp_code).deliver_later
  end

  def otp_valid?(submitted_code)
    with_redis { |r| r.get(otp_key) } == submitted_code
  end

  def increment_attempts
    with_redis do |r|
      attempts = r.incr(attempts_key)
      r.expire(attempts_key, 15.minutes.to_i)
      @target_user.update!(email_otp_attempts: attempts)
      attempts
    end
  end

  def attempts_exceeded?(attempts = nil)
    attempts ||= with_redis { |r| r.get(attempts_key).to_i }
    attempts >= 5
  end

  def lock_otp_generation
    with_redis { |r| r.setex(lock_key, 15.minutes.to_i, true) }
  end

  def ensure_two_factor_needed
    @target_user.present?
  end

  def with_redis
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
    @target_user.present?
  end

  def set_target_user
    if current_user.present?
      @target_user = current_user
      return
    end

    @target_user = User.find_by(id: session[:prep_user_id])
  end
end
