# == Schema Information
#
# Table name: ingredients
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  price      :decimal(8, 2)    default(0.0)
#  available  :boolean          default(TRUE)
#  allergen   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  weight     :integer          default(10), not null
#
class Ingredient < ApplicationRecord
  has_many :dish_ingredients, dependent: :destroy
  has_many :dishes, through: :dish_ingredients
  has_one :nutrition, dependent: :destroy

  has_one_attached :photo

  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :price,
            numericality: { greater_than_or_equal_to: 0, less_than: 100_000 }
  validates :weight,
            numericality: { only_integer: true, greater_than: 0, less_than: 10_000 }
  validates :photo,
            content_type: %w[image/png image/jpeg],
            size: { less_than: 5.megabytes }

  scope :available, -> { where(available: true) }
  scope :allergens, -> { where(allergen: true) }
end
