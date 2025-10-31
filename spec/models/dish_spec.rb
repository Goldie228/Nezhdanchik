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
  end
end
