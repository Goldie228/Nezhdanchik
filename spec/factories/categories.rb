# == Schema Information
#
# Table name: categories
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  description :text
#  slug        :string           not null
#  active      :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Категория #{n}" }
    sequence(:slug) { |n| "category-#{n}" }
    active { true }
  end
end
