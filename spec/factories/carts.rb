# == Schema Information
#
# Table name: carts
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  booking_id :bigint
#
FactoryBot.define do
  factory :cart do
    # Связь с пользователем обязательна. Валидация пользователя требует уникальности cart_id,
    # поэтому при создании пользователя через factory лучше явно не создавать корзину, чтобы избежать конфликтов,
    # если не используется стратегия создания после (after(:create)).
    association :user
  end
end
