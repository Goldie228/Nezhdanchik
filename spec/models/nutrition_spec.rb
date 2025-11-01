# == Schema Information
#
# Table name: nutritions
#
#  id              :bigint           not null, primary key
#  proteins        :decimal(5, 2)
#  fats            :decimal(5, 2)
#  carbohydrates   :decimal(5, 2)
#  nutritable_type :string           not null
#  nutritable_id   :bigint           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require "rails_helper"

RSpec.describe Nutrition, type: :model do
  let(:dish) { Dish.create!(title: "Маргарита", price: 10, slug: "margarita", category: Category.create!(name: "Пиццы", slug: "pizzas")) }

  describe "associations" do
    it "belongs to a nutritable (dish)" do
      nutrition = Nutrition.new(nutritable: dish, proteins: 10, fats: 5, carbohydrates: 20)
      expect(nutrition.nutritable).to eq(dish)
    end
  end

  describe "validations" do
    it "is invalid without nutritable" do
      nutrition = Nutrition.new(proteins: 10, fats: 5, carbohydrates: 20)
      expect(nutrition).not_to be_valid
      expect(nutrition.errors[:nutritable]).to include("must exist")
    end

    it "allows nil values for macros" do
      nutrition = Nutrition.new(nutritable: dish)
      expect(nutrition).to be_valid
    end

    it "is invalid with negative values" do
      nutrition = Nutrition.new(nutritable: dish, proteins: -1, fats: -2, carbohydrates: -3)
      expect(nutrition).not_to be_valid
      expect(nutrition.errors[:proteins]).to include("must be greater than or equal to 0")
    end

    it "is invalid with too large values" do
      nutrition = Nutrition.new(nutritable: dish, proteins: 2000, fats: 2000, carbohydrates: 2000)
      expect(nutrition).not_to be_valid
    end

    it "is valid with proper values" do
      nutrition = Nutrition.new(nutritable: dish, proteins: 12.5, fats: 8.2, carbohydrates: 30.0)
      expect(nutrition).to be_valid
    end
  end
end
