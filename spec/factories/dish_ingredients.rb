# == Schema Information
#
# Table name: dish_ingredients
#
#  id            :bigint           not null, primary key
#  dish_id       :bigint           not null
#  ingredient_id :bigint           not null
#  default       :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :dish_ingredient do
    # Обязательная связь с блюдом для формирования состава
    association :dish
    # Обязательная связь с ингредиентом
    association :ingredient

    # По умолчанию ингредиент включен в состав блюда при заказе
    default { true }
  end
end
