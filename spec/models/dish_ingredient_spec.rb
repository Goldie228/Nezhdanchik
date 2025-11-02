# == Schema Information
#
# Table name: dish_ingredients
#
#  id            :bigint           not null, primary key
#  dish_id       :bigint           not null
#  ingredient_id :bigint           not null
#  default       :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require "rails_helper"

RSpec.describe DishIngredient, type: :model do
  let!(:dish) { Dish.create!(title: "Pizza", slug: "pizza", price: 10, category: Category.create!(name: "Main", slug: "main")) }
  let!(:ingredient) { Ingredient.create!(name: "Cheese", price: 1.5) }

  it "is valid with valid attributes" do
    di = DishIngredient.new(dish: dish, ingredient: ingredient, default: true)
    expect(di).to be_valid
  end

  it "is invalid without dish" do
    di = DishIngredient.new(ingredient: ingredient)
    expect(di).not_to be_valid
  end

  it "is invalid without ingredient" do
    di = DishIngredient.new(dish: dish)
    expect(di).not_to be_valid
  end

  it "enforces uniqueness of dish and ingredient pair" do
    DishIngredient.create!(dish: dish, ingredient: ingredient)
    duplicate = DishIngredient.new(dish: dish, ingredient: ingredient)
    expect(duplicate).not_to be_valid
  end
end
