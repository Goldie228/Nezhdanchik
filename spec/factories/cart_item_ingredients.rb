# == Schema Information
#
# Table name: cart_item_ingredients
#
#  id              :bigint           not null, primary key
#  cart_item_id    :bigint           not null
#  ingredient_id   :bigint           not null
#  included        :boolean          default(TRUE), not null
#  default_in_dish :boolean          default(TRUE), not null
#  price           :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
FactoryBot.define do
  factory :cart_item_ingredient do
    association :cart_item
    association :ingredient
    included { true }
    default_in_dish { true }
    price { 150 }
  end
end
