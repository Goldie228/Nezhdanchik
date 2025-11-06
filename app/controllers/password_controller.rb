class PasswordController < ApplicationController
  before_action :authenticate_user!, only: [ :change, :update ]
  before_action :set_reset_token_from_params, only: [ :reset, :update_by_token ]
  before_action :validate_reset_token, only: [ :reset, :update_by_token ]

  TOKEN_EXPIRY = 2.hours

  def change
  end

  def update
    current_password = params[:current_password]
    new_password = params[:new_password]
    password_confirmation = params[:password_confirmation]

    unless current_user.authenticate(current_password)
      flash.now[:alert] = "Неверный текущий пароль"
      render :change, status: :unprocessable_entity and return
    end

    if new_password != password_confirmation
      flash.now[:alert] = "Новый пароль и его подтверждение не совпадают"
      render :change, status: :unprocessable_entity and return
    end

    if new_password.length < 8
      flash.now[:alert] = "Новый пароль должен содержать минимум 8 символов"
      render :change, status: :unprocessable_entity and return
    end

    if current_user.update(password: new_password)
      session[:password_changed] = true
      session.delete(:user_id)

      redirect_to password_success_path, notice: "Пароль успешно изменен!"
    else
      flash.now[:alert] = "Произошла ошибка: #{current_user.errors.full_messages.to_sentence}"
      render :change, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Error in PasswordController#update: #{e.class} #{e.message}"
    flash.now[:alert] = "Произошла непредвиденная ошибка. Попробуйте еще раз."
    render :change, status: :service_unavailable
  end

  def forgot
  end

  def create_reset_token
    email = params[:email]&.strip.downcase
    user = User.find_by(email: email)

    if user.present?
      token = generate_secure_token
      params[:token] = token

      with_redis do |r|
        r.setex(
          "password_reset:#{token}",
          TOKEN_EXPIRY.to_i,
          { user_id: user.id, created_at: Time.current.iso8601 }.to_json
        )
      end
      UserMailer.password_reset(user, token).deliver_later
      Rails.logger.info "Password reset token for #{user.email}: #{token}"

      redirect_to root_path, notice: "Ссылка на сброс отправлена на Вашу электронную почту" and return
    end

    redirect_to password_forgot_path, alert: "Электронная почта не найдена"
  rescue => e
    Rails.logger.error "Error in PasswordController#create_reset_token: #{e.class} #{e.message}"
    redirect_to password_forgot_path, alert: "Произошла ошибка. Пожалуйста, попробуйте позже."
  end

  def reset
  end

  def update_by_token
    new_password = params[:new_password]
    password_confirmation = params[:password_confirmation]

    if new_password != password_confirmation
      flash.now[:alert] = "Пароль и его подтверждение не совпадают"
      render :reset, status: :unprocessable_entity and return
    end

    if new_password.length < 8
      flash.now[:alert] = "Пароль должен содержать минимум 8 символов"
      render :reset, status: :unprocessable_entity and return
    end

    if @user.update(password: new_password)
      with_redis { |r| r.del("password_reset:#{@token}") }
      session[:password_changed] = true
      redirect_to password_success_path, notice: "Ваш пароль был успешно изменен."
    else
      flash.now[:alert] = "Не удалось обновить пароль: #{@user.errors.full_messages.to_sentence}"
      render :reset, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Error in PasswordController#update_by_token: #{e.class} #{e.message}"
    flash.now[:alert] = "Произошла непредвиденная ошибка. Попробуйте еще раз."
    render :reset, status: :service_unavailable
  end

  def success
    if session[:password_changed]
      session.delete(:password_changed)
      redirect_to root_path
    end
  end

  private

  def set_reset_token_from_params
    @token = params[:token]
  end

  def validate_reset_token
    if @token.blank?
      redirect_to password_forgot_path, alert: "Недействительная ссылка для сброса пароля."
      return
    end

    data = with_redis { |r| r.get("password_reset:#{@token}") }
    if data.blank?
      redirect_to password_forgot_path, alert: "Ссылка для сброса пароля недействительна или истекла."
      return
    end

    user_data = JSON.parse(data)
    @user = User.find_by(id: user_data["user_id"])

    if @user.blank?
      redirect_to password_forgot_path, alert: "Пользователь не найден."
    end
  end

  def generate_secure_token
    SecureRandom.urlsafe_base64(32)
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
