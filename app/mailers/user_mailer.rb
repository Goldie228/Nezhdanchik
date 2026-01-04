
class UserMailer < ApplicationMailer
  # Отправка OTP кода (например, для входа или подтверждения действий)
  def email_otp
    @user = params[:user]
    @code = params[:code]
    mail(to: @user.email, subject: "Ваш код подтверждения")
  end

  # Отправка ссылки для подтверждения смены email.
  # Важно: письмо отправляется на НОВЫЙ адрес, чтобы подтвердить владение им.
  def email_change_confirmation
    @user = params[:user]
    @new_email = params[:new_email]
    @token = params[:token]

    # Формируем абсолютную ссылку для перехода из письма
    # Используем переменные окружения для гибкости (dev vs prod)
    @confirmation_url = "#{ENV['APP_PROTOCOL'] || 'http'}://#{ENV['APP_HOST'] || 'localhost:3000'}/email/confirm/#{@token}"

    mail(to: @new_email, subject: "Подтверждение изменения адреса электронной почты")
  end

  # Отправка кода для двухфакторной аутентификации (2FA).
  # Принимает аргументы напрямую, так как вызывается как .deliver_later
  def two_factor_authentication(user, otp_code)
    @user = user
    @otp_code = otp_code

    mail(
      to: @user.email,
      subject: 'Код подтверждения для подтверждения почты "Нежданчик"'
    )
  end

  # Отправка ссылки для сброса пароля.
  # Генерирует одноразовый токен для безопасного сброса.
  def password_reset(user, token)
    @user = user
    @token = token

    @reset_url = "#{ENV['APP_PROTOCOL'] || 'http'}://#{ENV['APP_HOST'] || 'localhost:3000'}/password/reset/#{@token}"

    mail(to: @user.email, subject: 'Сброс пароля для "Нежданчик"')
  end

  private

  # Вспомогательный метод для генерации URL подтверждения.
  # Инкапсулирует логику формирования ссылки (хост + протокол + путь).
  def email_change_confirmation_url(token)
    "#{ENV['APP_PROTOCOL'] || 'http'}://#{ENV['APP_HOST'] || 'localhost:3000'}/email/confirm/#{token}"
  end
end
