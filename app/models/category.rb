# == Schema Information
#
# Table name: categories
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  description :text
#  slug        :string           not null
#  active      :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Category < ApplicationRecord
  has_many :dishes
  has_one_attached :photo

  validates :name, presence: true, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :description, length: { maximum: 2000 }, allow_blank: true
  validates :photo,
    content_type: [ "image/png", "image/jpeg" ],
    size: { less_than: 5.megabytes }
  scope :active, -> { where(active: true) }
end
