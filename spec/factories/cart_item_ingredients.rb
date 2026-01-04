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
    # Связь с позицией корзины обязательна (принадлежность ингредиента конкретному товару)
    association :cart_item
    # Связь с ингредиентом обязательна для получения цены и названия
    association :ingredient

    # По умолчанию ингредиент включен в блюдо
    included { true }
    # По умолчанию ингредиент является стандартным для этого блюда (не добавлен пользователем)
    default_in_dish { true }
    # Цена хранится в копейках/центах (integer), например 1.50 рубля = 150
    price { 150 }
  end
end
