# == Schema Information
#
# Table name: orders
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  order_number :string           not null
#  total_amount :decimal(10, 2)   not null
#  status       :string           default("pending")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  booking_id   :bigint
#
class Order < ApplicationRecord
  belongs_to :user
  belongs_to :booking, optional: true
  has_many :order_items, dependent: :destroy
  has_many :dishes, through: :order_items

  validates :order_number, uniqueness: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

  before_validation :generate_order_number, on: :create
  before_validation :set_default_total_amount

  def generate_order_number
    self.order_number ||= "ORD#{Time.current.to_i}#{rand(100..999)}"
  end

  def calculate_total
    update(total_amount: order_items.sum(:total_price))
  end

  private

  def set_default_total_amount
    self.total_amount = 0 if total_amount.nil?
  end
end
