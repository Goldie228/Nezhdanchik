# == Schema Information
#
# Table name: order_items
#
#  id                   :bigint           not null, primary key
#  order_id             :bigint           not null
#  dish_id              :bigint           not null
#  quantity             :integer          not null
#  unit_price           :decimal(8, 2)    not null
#  total_price          :decimal(8, 2)    not null
#  special_instructions :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
FactoryBot.define do
  factory :order_item do
    association :order
    association :dish
    quantity { 1 }
    unit_price { 10.50 }
  end
end
