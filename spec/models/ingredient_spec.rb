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
end
