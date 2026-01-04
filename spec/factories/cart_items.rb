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
    # Связь с корзиной обязательна для группировки товаров пользователя
    association :cart
    # Связь с блюдом обязательна для получения цены и названия
    association :dish

    quantity { 1 }
    # Флаг active позволяет скрывать удаленные товары без физического удаления из БД
    active { true }
  end
end
