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
    # Связь с бронью опциональна, так как корзина может существовать без предзаказа стола
    it { should belong_to(:booking).optional }
    # dependent: :destroy автоматически удаляет позиции товара при удалении корзины
    it { should have_many(:cart_items).dependent(:destroy) }
    # Позволяет удобно получать уникальные блюда, добавленные в корзину
    it { should have_many(:dishes).through(:cart_items) }
  end

  describe 'validations' do
    subject { build(:cart, user: user) }
    it { should validate_presence_of(:user_id) }
    # У пользователя должна быть только одна активная корзина (параметр user_id уникален)
    it { should validate_uniqueness_of(:user_id) }
  end

  describe 'instance methods' do
    let!(:cart) { create(:cart, user: user) }
    let!(:dish1) { create(:dish, price: 10.50) }
    let!(:dish2) { create(:dish, price: 5.00) }

    context '#total_cents' do
      it 'calculates total sum of all cart items in cents' do
        # dish1: 1 * 10.50, dish2: 2 * 5.00 = 20.50 Итого: 2050 центов
        create(:cart_item, cart: cart, dish: dish1, quantity: 1)
        create(:cart_item, cart: cart, dish: dish2, quantity: 2)

        expect(cart.total_cents).to eq(2050)
      end

      it 'returns 0 for an empty cart' do
        # Избегаем ошибок деления на ноль или nil при работе с пустой корзиной
        expect(cart.total_cents).to eq(0)
      end
    end

    context '#total_items_count' do
      it 'calculates total number of items considering quantity' do
        # Суммирует количество (quantity) позиций, а не просто записи в таблице
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
      it 'creates a new cart if one does not exist for user' do
        # Реализует паттерн "Find or Create" для удобной работы с корзиной
        expect {
          Cart.for_user!(user)
        }.to change(Cart, :count).by(1)
      end

      it 'returns an existing cart if it already exists for user' do
        existing_cart = create(:cart, user: user)

        returned_cart = Cart.for_user!(user)
        expect(returned_cart).to eq(existing_cart)
        # Проверяет, что дубликаты не создаются
        expect {
          Cart.for_user!(user)
        }.not_to change(Cart, :count)
      end
    end
  end
end
