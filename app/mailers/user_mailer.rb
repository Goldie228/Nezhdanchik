class UserMailer < ApplicationMailer
  def email_otp
    @user = params[:user]
    @code = params[:code]
    mail(to: @user.email, subject: "Ваш код подтверждения")
  end

  def email_change_confirmation
    @user = params[:user]
    @new_email = params[:new_email]
    @token = params[:token]

    # Формируем URL для подтверждения
    @confirmation_url = "#{ENV['APP_PROTOCOL'] || 'http'}://#{ENV['APP_HOST'] || 'localhost:3000'}/email/confirm/#{@token}"

    mail(to: @new_email, subject: "Подтверждение изменения адреса электронной почты")
  end

  def two_factor_authentication(user, otp_code)
    @user = user
    @otp_code = otp_code

    mail(
      to: @user.email,
      subject: 'Код подтверждения для подтверждения почты "Нежданчик"'
    )
  end

  def password_reset(user, token)
    @user = user
    @token = token

    # Формируем URL для сброса пароля
    @reset_url = "#{ENV['APP_PROTOCOL'] || 'http'}://#{ENV['APP_HOST'] || 'localhost:3000'}/password/reset/#{@token}"

    mail(to: @user.email, subject: 'Сброс пароля для "Нежданчик"')
  end

  private

  def email_change_confirmation_url(token)
    "#{ENV['APP_PROTOCOL'] || 'http'}://#{ENV['APP_HOST'] || 'localhost:3000'}/email/confirm/#{token}"
  end
end
