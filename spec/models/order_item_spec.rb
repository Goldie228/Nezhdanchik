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
require 'rails_helper'


RSpec.describe OrderItem, type: :model do
  describe 'associations' do
    it { should belong_to(:order) }
    it { should belong_to(:dish) }
  end

  describe 'callbacks' do
    context '#calculate_total_price' do
      it 'calculates total_price before saving a new record' do
        order_item = build(:order_item, quantity: 2, unit_price: 10.00)
        order_item.save

        expect(order_item.total_price).to eq(20.00)
      end

      it 'recalculates total_price before saving an updated record' do
        order_item = create(:order_item, quantity: 2, unit_price: 10.00)
        order_item.update(quantity: 3)

        order_item.reload
        expect(order_item.total_price).to eq(30.00)
      end
    end
  end
end
