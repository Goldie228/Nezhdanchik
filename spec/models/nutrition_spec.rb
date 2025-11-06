# == Schema Information
#
# Table name: nutritions
#
#  id            :bigint           not null, primary key
#  proteins      :decimal(5, 2)
#  fats          :decimal(5, 2)
#  carbohydrates :decimal(5, 2)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  dish_id       :bigint
#  ingredient_id :bigint
#
require "rails_helper"

RSpec.describe Nutrition, type: :model do
  let(:category) { Category.create!(name: "Пиццы", slug: "pizzas") }
  let(:dish) { Dish.create!(title: "Маргарита", price: 10, slug: "margarita", category: category) }

  describe "validations" do
    it "is invalid without dish or ingredient" do
      nutrition = Nutrition.new(proteins: 10, fats: 5, carbohydrates: 20)
      expect(nutrition).not_to be_valid
      expect(nutrition.errors[:base]).to include(I18n.t("errors.messages.must_have_parent"))
    end

    it "is valid with dish" do
      nutrition = Nutrition.new(dish: dish, proteins: 12.5, fats: 8.2, carbohydrates: 30.0)
      expect(nutrition).to be_valid
    end

    it "is invalid with negative values" do
      nutrition = Nutrition.new(dish: dish, proteins: -1, fats: -2, carbohydrates: -3)
      expect(nutrition).not_to be_valid
    end

    it "is invalid with too large values" do
      nutrition = Nutrition.new(dish: dish, proteins: 2000, fats: 2000, carbohydrates: 2000)
      expect(nutrition).not_to be_valid
    end
  end
end
