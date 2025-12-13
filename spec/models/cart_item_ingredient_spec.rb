# == Schema Information
#
# Table name: cart_item_ingredients
#
#  id              :bigint           not null, primary key
#  cart_item_id    :bigint           not null
#  ingredient_id   :bigint           not null
#  included        :boolean          default(TRUE), not null
#  default_in_dish :boolean          default(TRUE), not null
#  price           :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require 'rails_helper'


RSpec.describe CartItemIngredient, type: :model do
  describe 'associations' do
    subject { create(:cart_item_ingredient) }
    it { should belong_to(:cart_item) }
    it { should belong_to(:ingredient) }
  end

  describe 'validations' do
    subject { build(:cart_item_ingredient) }
    it { should validate_presence_of(:cart_item) }
    it { should validate_presence_of(:ingredient) }
    it { should validate_inclusion_of(:included).in_array([ true, false ]) }
    it { should validate_inclusion_of(:default_in_dish).in_array([ true, false ]) }
    it { should validate_numericality_of(:price).only_integer.is_greater_than_or_equal_to(0) }

    it do
      cii = create(:cart_item_ingredient)
      should validate_uniqueness_of(:ingredient_id).scoped_to(:cart_item_id)
    end
  end

  describe 'instance methods' do
    context '#added_by_user?' do
      it 'returns true if ingredient was not in dish by default and is included' do
        cii = build(:cart_item_ingredient, default_in_dish: false, included: true)
        expect(cii.added_by_user?).to be true
      end

      it 'returns false otherwise' do
        cii = build(:cart_item_ingredient, default_in_dish: true, included: true)
        expect(cii.added_by_user?).to be false
      end
    end

    context '#removed_by_user?' do
      it 'returns true if ingredient was in dish by default and is not included' do
        cii = build(:cart_item_ingredient, default_in_dish: true, included: false)
        expect(cii.removed_by_user?).to be true
      end

      it 'returns false otherwise' do
        cii = build(:cart_item_ingredient, default_in_dish: false, included: true)
        expect(cii.removed_by_user?).to be false
      end
    end
  end
end
