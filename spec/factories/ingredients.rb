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
    sequence(:name) { |n| "My Ingredient #{n}" }
    price { 1.50 }
    weight { 10 }
  end
end
