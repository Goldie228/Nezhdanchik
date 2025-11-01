# == Schema Information
#
# Table name: nutritions
#
#  id              :bigint           not null, primary key
#  proteins        :decimal(5, 2)
#  fats            :decimal(5, 2)
#  carbohydrates   :decimal(5, 2)
#  nutritable_type :string           not null
#  nutritable_id   :bigint           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Nutrition < ApplicationRecord
  belongs_to :nutritable, polymorphic: true

  validates :nutritable, presence: true

  validates :proteins, :fats, :carbohydrates,
            numericality: { greater_than_or_equal_to: 0, less_than: 1000 },
            allow_nil: true
end
