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
class DishIngredient < ApplicationRecord
  # Связь с блюдом, к которому относится ингредиент
  belongs_to :dish
  # Связь с конкретным ингредиентом (продукт)
  belongs_to :ingredient

  # Гарантирует, что один и тот же ингредиент не может быть добавлен в одно блюдо дважды
  validates :dish_id, uniqueness: { scope: :ingredient_id }
  # Указывает, входит ли ингредиент в состав блюда по умолчанию (или является дополнением)
  validates :default, inclusion: { in: [ true, false ] }
end
