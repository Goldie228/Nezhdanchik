# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  email              :string           not null
#  phone              :string           not null
#  first_name         :string(255)      not null
#  last_name          :string(255)      not null
#  middle_name        :string(255)
#  role               :integer          default("customer"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  password_digest    :string           not null
#  email_otp_code     :string
#  email_otp_sent_at  :datetime
#  email_otp_attempts :integer          default(0), not null
#  two_factor_enabled :boolean          default(FALSE), not null
#
class User < ApplicationRecord
  # Добавляет методы authenticate и password_digest для безопасной работы с паролями (gem bcrypt)
  has_secure_password

  # Константы безопасности для OTP (One-Time Password)
  OTP_TTL = 5.minutes           # Время жизни кода подтверждения
  MAX_OTP_ATTEMPTS = 5         # Максимальное количество попыток ввода кода
  OTP_LENGTH = 6                # Длина OTP-кода

  # Перечисление ролей пользователя. default: :customer
  # Использует префикс для генерации методов типа role_customer?, role_admin?
  enum :role, { customer: 0, manager: 1, admin: 2 }, default: :customer, prefix: :role

  # Связи пользователя с данными приложения
  has_one :cart, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :orders, dependent: :destroy

  # Валидация Email: обязательность, уникальность (без учета регистра), формат и длина
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { maximum: 255 },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  # Валидация телефона: обязательность, уникальность и формат (ровно 9 цифр без кода страны)
  validates :phone,
            presence: true,
            uniqueness: true,
            format: { with: /\A\d{9}\z/, message: :invalid_phone }

  # Валидация ФИО: обязательность имени и фамилии, опциональность отчества, ограничение длины
  validates :first_name, :last_name,
            presence: true,
            length: { maximum: 255 }

  validates :middle_name,
            length: { maximum: 255 },
            allow_blank: true

  # Валидация пароля: минимальная длина (только при создании/смене)
  validates :password,
            length: { minimum: 6 },
            allow_nil: true

  # Генерирует новый OTP-код, сохраняет его в БД и отправляет письмо
  def generate_email_otp!
    # Генерация 6-значного числа (первые цифры не должны быть нулем)
    code = rand.to_s[2..(1 + OTP_LENGTH)]

    # Сохраняем код, время отправки и сбрасываем счетчик попыток
    update!(
      email_otp_code: code,
      email_otp_sent_at: Time.current,
      email_otp_attempts: 0
    )
    # Асинхронная отправка письма через ActiveJob
    UserMailer.with(user: self, code: code).email_otp.deliver_later
  end

  # Проверяет валидность OTP-кода с учетом времени жизни и количества попыток
  def email_otp_valid?(code)
    # Проверка на истечение срока действия (TTL)
    return false if email_otp_sent_at.nil?
    # Добавление ошибки в объект, чтобы можно было показать текст пользователю
    errors.add(:base, I18n.t("users.otp.expired")) if Time.current > (email_otp_sent_at + OTP_TTL)
    return false if Time.current > (email_otp_sent_at + OTP_TTL)

    # Проверка на превышение лимита попыток (защита от перебора)
    errors.add(:base, I18n.t("users.otp.max_attempts")) if email_otp_attempts >= MAX_OTP_ATTEMPTS
    return false if email_otp_attempts >= MAX_OTP_ATTEMPTS

    # Безопасное сравнение строк (предотвращает timing attacks)
    if ActiveSupport::SecurityUtils.secure_compare(code.to_s, email_otp_code.to_s)
      # При успехе — очищаем данные
      clear_email_otp!
      true
    else
      # При неудаче — увеличиваем счетчик попыток и сохраняем
      increment!(:email_otp_attempts)
      errors.add(:base, I18n.t("users.otp.invalid"))
      false
    end
  end

  # Проверяет, находится ли процесс смены email в ожидании (ищет токены в Redis)
  def email_change_pending?
    tokens = REDIS_CLIENT.keys("email_change:*")
    result = tokens.any? do |token|
      data = JSON.parse(REDIS_CLIENT.get(token))
      data["user_id"] == id
    end

    if result
      errors.add(:base, I18n.t("users.otp.email_change_pending"))
    end

    result
  rescue
    false
  end

  # Сбрасывает OTP-данные пользователя в БД
  def clear_email_otp!
    update!(email_otp_code: nil, email_otp_sent_at: nil, email_otp_attempts: 0)
  end

  # Форматирует номер телефона в полный формат (+375 ...) на основе 9 цифр
  def formatted_phone
    return "" if phone.blank?

    digits = phone.gsub(/\D/, "")
    return phone if digits.length < 9

    operator = digits[0..1]
    first_part = digits[2..4]
    second_part = digits[5..6]
    third_part = digits[7..8]

    "+375 (#{operator}) #{first_part}-#{second_part}-#{third_part}"
  end

  # Возвращает полное ФИО одной строкой
  def full_name
    [ last_name, first_name, middle_name ].compact.join(" ")
  end

  # Проверяет, является ли пользователь администратором
  def admin?
    role == "admin"
  end

  # Проверяет, является ли пользователь менеджером или администратором (персонал)
  def manager?
    [ "admin", "manager" ].include?(role)
  end

  # Проверяет, подтвердил ли пользователь почту (включена ли 2FA)
  def confirmed?
    two_factor_enabled
  end
end
