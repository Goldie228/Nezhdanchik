# == Schema Information
#
# Table name: ingredients
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  price      :decimal(8, 2)    default(0.0)
#  available  :boolean          default(TRUE)
#  allergen   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  weight     :integer          default(10), not null
#
FactoryBot.define do
  factory :ingredient do
    # Используем sequence для генерации уникальных имен, так как валидация требует их уникальности
    sequence(:name) { |n| "My Ingredient #{n}" }
    price { 1.50 }
    # Значение по умолчанию из схемы БД, но полезно указать явно для предсказуемости тестов
    weight { 10 }
  end
end
