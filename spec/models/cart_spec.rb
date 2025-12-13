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
require 'rails_helper'


RSpec.describe Cart, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    subject { create(:cart, user: user) }
    it { should belong_to(:user) }
    it { should belong_to(:booking).optional }
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:dishes).through(:cart_items) }
  end

  describe 'validations' do
    subject { build(:cart, user: user) }
    it { should validate_presence_of(:user_id) }
    it { should validate_uniqueness_of(:user_id) }
  end

  describe 'instance methods' do
    let!(:cart) { create(:cart, user: user) }
    let!(:dish1) { create(:dish, price: 10.50) }
    let!(:dish2) { create(:dish, price: 5.00) }

    context '#total_cents' do
      it 'calculates the total sum of all cart items in cents' do
        create(:cart_item, cart: cart, dish: dish1, quantity: 1)
        create(:cart_item, cart: cart, dish: dish2, quantity: 2)

        expect(cart.total_cents).to eq(2050)
      end

      it 'returns 0 for an empty cart' do
        expect(cart.total_cents).to eq(0)
      end
    end

    context '#total_items_count' do
      it 'calculates the total number of items considering quantity' do
        create(:cart_item, cart: cart, quantity: 2)
        create(:cart_item, cart: cart, quantity: 3)

        expect(cart.total_items_count).to eq(5)
      end

      it 'returns 0 for an empty cart' do
        expect(cart.total_items_count).to eq(0)
      end
    end
  end

  describe 'class methods' do
    context '.for_user!' do
      it 'creates a new cart if one does not exist for the user' do
        expect {
          Cart.for_user!(user)
        }.to change(Cart, :count).by(1)
      end

      it 'returns an existing cart if it already exists for the user' do
        existing_cart = create(:cart, user: user)

        returned_cart = Cart.for_user!(user)
        expect(returned_cart).to eq(existing_cart)
        expect {
          Cart.for_user!(user)
        }.not_to change(Cart, :count)
      end
    end
  end
end
