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
  has_secure_password

  OTP_TTL = 5.minutes
  MAX_OTP_ATTEMPTS = 5
  OTP_LENGTH = 6

  enum :role, { customer: 0, manager: 1, admin: 2 }, default: :customer, prefix: true

  has_one :cart, dependent: :destroy

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { maximum: 255 },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :phone,
            presence: true,
            uniqueness: true,
            format: { with: /\A\d{9}\z/, message: :invalid_phone }

  validates :first_name, :last_name,
            presence: true,
            length: { maximum: 255 }

  validates :middle_name,
            length: { maximum: 255 },
            allow_blank: true

  validates :password,
            length: { minimum: 6 },
            allow_nil: true

  def generate_email_otp!
    code = rand.to_s[2..(1 + OTP_LENGTH)]
    update!(
      email_otp_code: code,
      email_otp_sent_at: Time.current,
      email_otp_attempts: 0
    )
    UserMailer.with(user: self, code: code).email_otp.deliver_later
  end

  def email_otp_valid?(code)
    return false if email_otp_sent_at.nil?
    return false if Time.current > (email_otp_sent_at + OTP_TTL)
    return false if email_otp_attempts >= MAX_OTP_ATTEMPTS
    if ActiveSupport::SecurityUtils.secure_compare(code.to_s, email_otp_code.to_s)
      clear_email_otp!
      true
    else
      increment!(:email_otp_attempts)
      false
    end
  end

  def email_change_pending?
    tokens = REDIS_CLIENT.keys("email_change:*")
    tokens.any? do |token|
      data = JSON.parse(REDIS_CLIENT.get(token))
      data["user_id"] == id
    end
  rescue
    false
  end

  def clear_email_otp!
    update!(email_otp_code: nil, email_otp_sent_at: nil, email_otp_attempts: 0)
  end

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

  def full_name
    [ last_name, first_name, middle_name ].compact.join(" ")
  end

  def admin?
    role == "admin"
  end

  def manager?
    [ "admin", "manager" ].include?(role)
  end

  def confirmed?
    two_factor_enabled
  end
end
