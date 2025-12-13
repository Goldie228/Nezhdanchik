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
require 'rails_helper'


RSpec.describe Order, type: :model do
  let(:user) { create(:user) }

  describe 'validations' do
    it 'validates numericality of total_amount' do
      order = build(:order, user: user, total_amount: -10.0)
      expect(order).not_to be_valid

      expect(order.errors[:total_amount]).to include('должен быть больше или равен 0')
    end

    it 'is valid with zero total_amount' do
      order = build(:order, user: user, total_amount: 0.0)
      expect(order).to be_valid
    end

    it 'is valid with positive total_amount' do
      order = build(:order, user: user, total_amount: 100.0)
      expect(order).to be_valid
    end
  end

  describe 'callbacks' do
    it 'sets default total_amount to 0 if nil' do
      order = Order.new(user: user, total_amount: nil)
      order.valid?
      expect(order.total_amount).to eq(0.0)
    end
  end

  describe '#calculate_total' do
    let(:user) { create(:user) }
    let(:order) { create(:order, user: user) }
    let(:dish) { create(:dish) }

    it 'calculates total from order items' do
      create(:order_item, order: order, dish: dish, quantity: 2, unit_price: 10.0, total_price: 20.0)
      create(:order_item, order: order, dish: dish, quantity: 1, unit_price: 15.0, total_price: 15.0)

      order.calculate_total
      expect(order.total_amount).to eq(35.0)
    end

    it 'updates total when order items change' do
      order = create(:order, user: user, total_amount: 50.0)

      create(:order_item, order: order, dish: dish, quantity: 1, unit_price: 25.0, total_price: 25.0)

      order.calculate_total
      expect(order.total_amount).to eq(25.0)
    end
  end
end
