# == Schema Information
#
# Table name: ingredients
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  price      :decimal(8, 2)    default(0.0)
#  available  :boolean          default(TRUE)
#  allergen   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  weight     :integer          default(10), not null
#
require "rails_helper"

RSpec.describe Ingredient, type: :model do
  it "is valid with valid attributes" do
    ingredient = Ingredient.new(name: "Cheese", price: 1.5, available: true, allergen: false)
    expect(ingredient).to be_valid
  end

  it "is invalid without a name" do
    ingredient = Ingredient.new(price: 1.5)
    expect(ingredient).not_to be_valid
    expect(ingredient.errors[:name]).to include("can't be blank")
  end

  it "is invalid with duplicate name" do
    Ingredient.create!(name: "Cheese", price: 1.5)
    duplicate = Ingredient.new(name: "Cheese", price: 2.0)
    expect(duplicate).not_to be_valid
  end

  it "is invalid with negative price" do
    ingredient = Ingredient.new(name: "Tomato", price: -1)
    expect(ingredient).not_to be_valid
  end

  it "can have an attached photo" do
    ingredient = Ingredient.create!(name: "Cheese", price: 1.5)
    ingredient.photo.attach(
      io: StringIO.new("fake image content"),
      filename: "test.png",
      content_type: "image/png"
    )
    expect(ingredient.photo).to be_attached
  end

  describe "validations for weight" do
    it "is valid with default weight 10" do
      ingredient = Ingredient.new(name: "Cheese", price: 1.5)
      expect(ingredient.weight).to eq(10)
      expect(ingredient).to be_valid
    end

    it "is invalid with zero weight" do
      ingredient = Ingredient.new(name: "Cheese", price: 1.5, weight: 0)
      expect(ingredient).not_to be_valid
      expect(ingredient.errors[:weight]).to be_present
    end

    it "is invalid with negative weight" do
      ingredient = Ingredient.new(name: "Cheese", price: 1.5, weight: -5)
      expect(ingredient).not_to be_valid
      expect(ingredient.errors[:weight]).to be_present
    end

    it "is invalid with non-integer weight" do
      ingredient = Ingredient.new(name: "Cheese", price: 1.5, weight: 12.5)
      expect(ingredient).not_to be_valid
      expect(ingredient.errors[:weight]).to be_present
    end

    it "is invalid with too large weight" do
      ingredient = Ingredient.new(name: "Cheese", price: 1.5, weight: 20_000)
      expect(ingredient).not_to be_valid
      expect(ingredient.errors[:weight]).to be_present
    end
  end

  describe "scopes" do
    it "returns only available ingredients" do
      available = Ingredient.create!(name: "Tomato", price: 1.0, available: true)
      unavailable = Ingredient.create!(name: "Onion", price: 0.5, available: false)

      expect(Ingredient.available).to include(available)
      expect(Ingredient.available).not_to include(unavailable)
    end

    it "returns only allergens" do
      allergen = Ingredient.create!(name: "Peanut", price: 2.0, allergen: true)
      non_allergen = Ingredient.create!(name: "Cheese", price: 1.5, allergen: false)

      expect(Ingredient.allergens).to include(allergen)
      expect(Ingredient.allergens).not_to include(non_allergen)
    end
  end

  describe "associations" do
    it "can have nutrition info for ingredient" do
      ingredient = Ingredient.create!(name: "Cheese", price: 1.5)
      nutrition = Nutrition.create!(ingredient: ingredient, proteins: 10, fats: 5, carbohydrates: 20)

      expect(ingredient.nutrition).to eq(nutrition)
      expect(nutrition.ingredient).to eq(ingredient)
    end
  end
end
