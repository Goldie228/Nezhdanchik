# == Schema Information
#
# Table name: dishes
#
#  id                   :bigint           not null, primary key
#  title                :string           not null
#  description          :text
#  price                :decimal(10, 2)   not null
#  slug                 :string           not null
#  active               :boolean          default(TRUE)
#  cooking_time_minutes :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  category_id          :bigint
#  weight               :integer          default(100), not null
#
require "rails_helper"

RSpec.describe Dish, type: :model do
  let(:category) { Category.create!(name: "Пиццы", slug: "pizzas") }

  describe "associations" do
    it "belongs to category" do
      dish = Dish.new(title: "Маргарита", price: 10, slug: "margarita", category: category)
      expect(dish.category).to eq(category)
    end
  end

  describe "validations for photos" do
    it "is invalid if photo is not an image" do
      dish = Dish.new(title: "Маргарита", price: 10, slug: "margarita", category: category)
      dish.photos.attach(
        io: StringIO.new("not an image"),
        filename: "file.pdf",
        content_type: "application/pdf"
      )
      expect(dish).not_to be_valid
      expect(dish.errors[:photos].join).to include("invalid content type")
    end

    it "is invalid if photo is too large" do
      dish = Dish.new(title: "Маргарита", price: 10, slug: "margarita", category: category)
      big_file = StringIO.new("0" * 6.megabytes)
      dish.photos.attach(
        io: big_file,
        filename: "big.png",
        content_type: "image/png"
      )
      expect(dish).not_to be_valid
      expect(dish.errors[:photos].join).to include("less than 5 MB")
    end

    it "is valid with a proper image" do
      dish = Dish.new(title: "Маргарита", price: 10, slug: "margarita", category: category)
      dish.photos.attach(
        io: StringIO.new("fake image content"),
        filename: "ok.png",
        content_type: "image/png"
      )
      expect(dish).to be_valid
    end
  end

  describe "validations" do
    it "is invalid without title" do
      dish = Dish.new(price: 10, slug: "slug", category: category)
      expect(dish).not_to be_valid
      expect(dish.errors[:title]).to include("can't be blank")
    end

    it "is invalid without price" do
      dish = Dish.new(title: "Маргарита", slug: "slug", category: category)
      expect(dish).not_to be_valid
    end

    it "is invalid with negative price" do
      dish = Dish.new(title: "Маргарита", price: -5, slug: "slug", category: category)
      expect(dish).not_to be_valid
    end

    it "is invalid without slug" do
      dish = Dish.new(title: "Маргарита", price: 10, category: category)
      expect(dish).not_to be_valid
    end

    it "is invalid with duplicate slug" do
      Dish.create!(title: "Маргарита", price: 10, slug: "margarita", category: category)
      dup = Dish.new(title: "Пепперони", price: 12, slug: "margarita", category: category)
      expect(dup).not_to be_valid
      expect(dup.errors[:slug]).to include("has already been taken")
    end

    it "is valid with all required attributes" do
      dish = Dish.new(title: "Маргарита", price: 10, slug: "margarita", category: category)
      expect(dish).to be_valid
    end

    it "is invalid if cooking_time_minutes is not integer" do
      dish = Dish.new(title: "Маргарита", price: 10, slug: "margarita", category: category, cooking_time_minutes: 12.5)
      expect(dish).not_to be_valid
      expect(dish.errors[:cooking_time_minutes]).to include("must be an integer")
    end

    it "is invalid if cooking_time_minutes is zero or negative" do
      dish = Dish.new(title: "Маргарита", price: 10, slug: "margarita", category: category, cooking_time_minutes: 0)
      expect(dish).not_to be_valid
    end

    it "is invalid if description is too long" do
      dish = Dish.new(title: "Маргарита", price: 10, slug: "margarita", category: category, description: "a" * 6000)
      expect(dish).not_to be_valid
      expect(dish.errors[:description]).to include("is too long (maximum is 5000 characters)")
    end
  end

  describe "scopes" do
    it "returns only active dishes" do
      active_dish = Dish.create!(title: "Активная", price: 10, slug: "active", category: category, active: true)
      inactive_dish = Dish.create!(title: "Неактивная", price: 10, slug: "inactive", category: category, active: false)

      expect(Dish.active).to include(active_dish)
      expect(Dish.active).not_to include(inactive_dish)
    end
  end

  describe "validations for weight" do
    it "is valid with default weight 100" do
      dish = Dish.new(title: "Маргарита", price: 10, slug: "margarita", category: category)
      expect(dish.weight).to eq(100)
      expect(dish).to be_valid
    end

    it "is invalid with zero weight" do
      dish = Dish.new(title: "Маргарита", price: 10, slug: "margarita", category: category, weight: 0)
      expect(dish).not_to be_valid
      expect(dish.errors[:weight]).to include("must be greater than 0")
    end

    it "is invalid with negative weight" do
      dish = Dish.new(title: "Маргарита", price: 10, slug: "margarita", category: category, weight: -50)
      expect(dish).not_to be_valid
      expect(dish.errors[:weight]).to include("must be greater than 0")
    end

    it "is invalid with non-integer weight" do
      dish = Dish.new(title: "Маргарита", price: 10, slug: "margarita", category: category, weight: 99.5)
      expect(dish).not_to be_valid
      expect(dish.errors[:weight]).to include("must be an integer")
    end

    it "is invalid with too large weight" do
      dish = Dish.new(title: "Маргарита", price: 10, slug: "margarita", category: category, weight: 20_000)
      expect(dish).not_to be_valid
      expect(dish.errors[:weight]).to include("must be less than 10000")
    end
  end

  describe "associations" do
    it "can have nutrition info for dish" do
      dish = Dish.create!(title: "Маргарита", price: 10, slug: "margarita", category: category)
      nutrition = Nutrition.create!(dish: dish, proteins: 12, fats: 8, carbohydrates: 30)

      expect(dish.nutrition).to eq(nutrition)
      expect(nutrition.dish).to eq(dish)
    end
  end
end
