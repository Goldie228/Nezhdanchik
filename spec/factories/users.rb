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
FactoryBot.define do
  factory :user do
    email { "user@example.com" }
    phone { "291234567" }
    first_name { "John" }
    last_name { "Doe" }
    password { "password123" }
    password_confirmation { "password123" }
    role { 0 }

    trait :with_sequence do
      sequence(:email) { |n| "user#{n}@example.com" }
      sequence(:phone) { |n| "29123456#{n}" }
    end

    trait :admin do
      role { 1 }
    end
  end
end
