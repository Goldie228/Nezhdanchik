# == Schema Information
#
# Table name: dishes
#
#  id                   :bigint           not null, primary key
#  title                :string           not null
#  description          :text
#  price                :decimal(10, 2)   not null
#  slug                 :string           not null
#  active               :boolean          default(TRUE)
#  cooking_time_minutes :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  category_id          :bigint
#  weight               :integer          default(100), not null
#
class Dish < ApplicationRecord
  belongs_to :category
  has_many_attached :photos

  has_many :dish_ingredients, dependent: :destroy
  has_many :ingredients, through: :dish_ingredients
  has_one :nutrition, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }
  validates :price, presence: true,
                    numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000 }
  validates :slug, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :cooking_time_minutes,
            numericality: { only_integer: true, greater_than: 0 },
            allow_nil: true
  validates :description, length: { maximum: 5000 }, allow_blank: true
  validates :photos,
            content_type: %w[image/png image/jpeg],
            size: { less_than: 5.megabytes }
  validates :weight,
            numericality: { only_integer: true, greater_than: 0, less_than: 10_000 }

  scope :active, -> { where(active: true) }

  def default_ingredients
    ingredients.merge(DishIngredient.where(default: true))
  end

  def optional_ingredients
    ingredients.merge(DishIngredient.where(default: false))
  end
end
