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
    # Связь с заказом обязательна для корректной агрегации сумм
    association :order
    # Связь с блюдом обязательна для получения информации о позиции
    association :dish

    quantity { 1 }
    unit_price { 10.50 }
    # total_price рассчитывается автоматически через callback перед сохранением
    # (quantity * unit_price), поэтому здесь его можно не задавать явно
  end
end
