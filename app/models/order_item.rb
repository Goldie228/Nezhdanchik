# == Schema Information
#
# Table name: order_items
#
#  id                   :bigint           not null, primary key
#  order_id             :bigint           not null
#  dish_id              :bigint           not null
#  quantity             :integer          not null
#  unit_price           :decimal(8, 2)    not null
#  total_price          :decimal(8, 2)    not null
#  special_instructions :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :dish

  before_save :calculate_total_price

  def calculate_total_price
    self.total_price = quantity * unit_price
  end
end
