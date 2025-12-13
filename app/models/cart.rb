# == Schema Information
#
# Table name: carts
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  booking_id :bigint
#
class Cart < ApplicationRecord
  belongs_to :user
  belongs_to :booking, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :dishes, through: :cart_items

  validates :user_id, presence: true, uniqueness: true

  def total_cents
    cart_items.sum(&:subtotal_cents)
  end

  def total_items_count
    cart_items.sum(:quantity)
  end

  def self.for_user!(user)
    find_or_create_by!(user: user)
  end
end
