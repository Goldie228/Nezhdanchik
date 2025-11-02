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
  belongs_to :dish
  belongs_to :ingredient

  validates :dish_id, uniqueness: { scope: :ingredient_id }
  validates :default, inclusion: { in: [ true, false ] }
end
