# == Schema Information
#
# Table name: dishes
#
#  id                   :bigint           not null, primary key
#  title                :string           not null
#  description          :text
#  price                :decimal(10, 2)   not null
#  slug                 :string           not null
#  active               :boolean          default(TRUE)
#  cooking_time_minutes :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  category_id          :bigint
#  weight               :integer          default(100), not null
#
FactoryBot.define do
  factory :dish do
    sequence(:title) { |n| "Блюдо #{n}" }
    description { "Вкусное блюдо" }
    price { 100.0 }
    sequence(:slug) { |n| "dish-#{n}" }
    active { true }
    weight { 100 }
    category { create(:category) }
  end
end
