# == Schema Information
#
# Table name: nutritions
#
#  id            :bigint           not null, primary key
#  proteins      :decimal(5, 2)
#  fats          :decimal(5, 2)
#  carbohydrates :decimal(5, 2)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  dish_id       :bigint
#  ingredient_id :bigint
#
class Nutrition < ApplicationRecord
  belongs_to :dish, optional: true
  belongs_to :ingredient, optional: true

  validate :only_one_parent

  validates :proteins, :fats, :carbohydrates,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 1000
            },
            allow_nil: true

  private

  def only_one_parent
    if dish_id.blank? && ingredient_id.blank?
      errors.add(:base, :must_have_parent)
    elsif dish_id.present? && ingredient_id.present?
      errors.add(:base, :cannot_have_both)
    end
  end
end
