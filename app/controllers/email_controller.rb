class EmailController < ApplicationController
  before_action :authenticate_user!

  TOKEN_EXPIRY = 2.hours

  def confirmation
  end

  def change_status
    new_email = params[:email]&.strip

    if new_email.blank?
      flash.now[:alert] = "Адрес электронной почты не может быть пустым."
      return render :confirmation, status: :unprocessable_entity
    end

    unless URI::MailTo::EMAIL_REGEXP.match?(new_email)
      flash.now[:alert] = "Пожалуйста, введите корректный адрес электронной почты в формате 'имя@домен.com'."
      return render :confirmation, status: :unprocessable_entity
    end

    token = generate_secure_token

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

    UserMailer.with(user: current_user, new_email: new_email, token: token)
              .email_change_confirmation
              .deliver_later

    redirect_to profile_path, notice: "Письмо с подтверждением отправлено на #{new_email}"
  rescue => e
    Rails.logger.error "Error in EmailController#change_status: #{e.class} #{e.message}"
    flash.now[:alert] = "Произошла ошибка. Попробуйте позже."
    render :confirmation, status: :internal_server_error
  end

  def confirm
    token = params[:token]

    if token.blank?
      flash[:alert] = "Недействительная ссылка подтверждения"
      redirect_to profile_path and return
    end

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

    if User.where.not(id: user.id).exists?(email: data["new_email"])
      flash[:alert] = "Этот адрес электронной почты уже используется другим пользователем"
      redirect_to profile_path and return
    end

    user.update!(email: data["new_email"])
    with_redis { |r| r.del("email_change:#{token}") }

    @email = data["new_email"]
    current_user.update!(two_factor_enabled: true)

    render :success
  rescue => e
    Rails.logger.error "Error in EmailController#confirm: #{e.class} #{e.message}"
    flash[:alert] = "Произошла ошибка при подтверждении email: #{e.message}"
    redirect_to profile_path
  end

  private

  def generate_secure_token
    SecureRandom.urlsafe_base64(32)
  end

  def get_email_change_data(token)
    with_redis do |r|
      data_json = r.get("email_change:#{token}")
      data_json.present? ? JSON.parse(data_json) : nil
    end
  rescue => e
    Rails.logger.error "Error retrieving email change data: #{e.class} #{e.message}"
    nil
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
end
