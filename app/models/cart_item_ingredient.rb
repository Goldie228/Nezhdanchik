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
class CartItemIngredient < ApplicationRecord
  belongs_to :cart_item
  belongs_to :ingredient

  validates :cart_item, :ingredient, presence: true
  validates :included, :default_in_dish, inclusion: { in: [ true, false ] }
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :ingredient_id, uniqueness: { scope: :cart_item_id }

  def added_by_user?
    !default_in_dish && included
  end

  def removed_by_user?
    default_in_dish && !included
  end
end
