# == Schema Information
#
# Table name: cart_items
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cart_id    :bigint           not null
#  quantity   :integer          default(1), not null
#  active     :boolean          default(TRUE), not null
#  dish_id    :bigint           not null
#
require 'rails_helper'


RSpec.describe CartItem, type: :model do
  let(:user) { create(:user) }
  let(:cart) { create(:cart, user: user) }

  describe 'associations' do
    subject { create(:cart_item) }
    it { should belong_to(:cart) }
    it { should belong_to(:dish) }
    it { should have_many(:cart_item_ingredients).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:cart_item, cart: cart) }
    it { should validate_presence_of(:cart) }
    it { should validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
    it { should validate_inclusion_of(:active).in_array([ true, false ]) }
  end

  describe 'scopes' do
    let!(:active_item) { create(:cart_item, cart: cart, active: true) }
    let!(:inactive_item) { create(:cart_item, cart: cart, active: false) }

    it '.active returns only active items' do
      expect(CartItem.active).to include(active_item)
      expect(CartItem.active).not_to include(inactive_item)
    end
  end

  describe 'callbacks' do
    it 'builds ingredients from dish after creation' do
      test_dish = create(:dish)
      test_ingredient = create(:ingredient, price: 1.5)
      create(:dish_ingredient, dish: test_dish, ingredient: test_ingredient, default: true)

      cart_item = create(:cart_item, cart: cart, dish: test_dish)

      expect(cart_item.cart_item_ingredients.find_by(ingredient: test_ingredient)).to be_present

      cii = cart_item.cart_item_ingredients.find_by(ingredient: test_ingredient)
      expect(cii.price).to eq(150)
    end
  end

  describe 'instance methods' do
    let!(:ingredient1) { create(:ingredient, price: 1.50, weight: 20) }
    let!(:ingredient2) { create(:ingredient, price: 2.00, weight: 30) }
    let!(:dish) { create(:dish, price: 10.00, weight: 300) }
    let!(:di1) { create(:dish_ingredient, dish: dish, ingredient: ingredient1, default: true) }
    let!(:di2) { create(:dish_ingredient, dish: dish, ingredient: ingredient2, default: false) }
    let!(:cart_item) { create(:cart_item, cart: cart, dish: dish, quantity: 2) }

    context '#subtotal_cents' do
      it 'calculates subtotal correctly' do
        cart_item.cart_item_ingredients.find_by(ingredient: ingredient1).update!(included: false)
        cart_item.cart_item_ingredients.find_by(ingredient: ingredient2).update!(included: true)
        expect(cart_item.subtotal_cents).to eq(2100)
      end
    end

    context '#base_price_cents' do
      it 'returns dish price in cents' do
        expect(cart_item.base_price_cents).to eq(1000)
      end
    end

    context '#ingredients_extra_cents' do
      it 'calculates the sum of added and removed ingredients' do
        cart_item.cart_item_ingredients.find_by(ingredient: ingredient1).update!(included: false)
        cart_item.cart_item_ingredients.find_by(ingredient: ingredient2).update!(included: true)
        expect(cart_item.ingredients_extra_cents).to eq(50)
      end
    end

    context '#added_ingredient_ids' do
      it 'returns IDs of non-default ingredients added by user' do
        cart_item.cart_item_ingredients.find_by(ingredient: ingredient2).update!(included: true)
        expect(cart_item.added_ingredient_ids).to eq([ ingredient2.id ])
      end
    end

    context '#removed_ingredient_ids' do
      it 'returns IDs of default ingredients removed by user' do
        cart_item.cart_item_ingredients.find_by(ingredient: ingredient1).update!(included: false)
        expect(cart_item.removed_ingredient_ids).to eq([ ingredient1.id ])
      end
    end

    context '#matches_composition?' do
      it 'returns true if composition matches' do
        cart_item.cart_item_ingredients.find_by(ingredient: ingredient1).update!(included: false)
        cart_item.cart_item_ingredients.find_by(ingredient: ingredient2).update!(included: true)
        expect(cart_item.matches_composition?([ ingredient2.id ], [ ingredient1.id ])).to be true
      end

      it 'returns false if composition does not match' do
        expect(cart_item.matches_composition?([ 123 ], [ 456 ])).to be false
      end
    end

    context '#per_item_weight_g' do
      it 'calculates weight for a single item' do
        cart_item.cart_item_ingredients.find_by(ingredient: ingredient1).update!(included: false)
        cart_item.cart_item_ingredients.find_by(ingredient: ingredient2).update!(included: true)
        expect(cart_item.per_item_weight_g).to eq(310)
      end
    end

    context '#total_weight_g' do
      it 'calculates total weight for all items' do
        cart_item.cart_item_ingredients.find_by(ingredient: ingredient1).update!(included: false)
        cart_item.cart_item_ingredients.find_by(ingredient: ingredient2).update!(included: true)
        expect(cart_item.total_weight_g).to eq(620)
      end
    end
  end
end
