# == Schema Information
#
# Table name: cart_items
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cart_id    :bigint           not null
#  quantity   :integer          default(1), not null
#  active     :boolean          default(TRUE), not null
#  dish_id    :bigint           not null
#
FactoryBot.define do
  factory :cart_item do
    association :cart
    association :dish
    quantity { 1 }
    active { true }
  end
end
