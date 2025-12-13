# == Schema Information
#
# Table name: categories
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  description :text
#  slug        :string           not null
#  active      :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "rails_helper"


RSpec.describe Category, type: :model do
  describe "associations" do
    it "can have many dishes" do
      category = Category.create!(name: "Пиццы", slug: "pizzas")
      dish1 = Dish.create!(title: "Маргарита", price: 10, slug: "margarita", category: category)
      dish2 = Dish.create!(title: "Пепперони", price: 12, slug: "pepperoni", category: category)

      expect(category.dishes).to include(dish1, dish2)
    end

    it "can have a photo attached" do
      category = Category.create!(name: "Пиццы", slug: "pizzas")
      category.photo.attach(
        io: StringIO.new("fake image content"),
        filename: "test.png",
        content_type: "image/png"
      )
      expect(category.photo).to be_attached
    end
  end

  describe 'validations for photo' do
    it "is valid with a proper image" do
      category = Category.new(name: "Пиццы", slug: "pizzas")
      category.photo.attach(
        io: StringIO.new("fake image content"),
        filename: "ok.png",
        content_type: "image/png"
      )
      expect(category).to be_valid
    end
  end

  describe "validations" do
    it "is invalid without a name" do
      category = Category.new(slug: "pizzas")
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("не может быть пустым")
    end

    it "is invalid without a slug" do
      category = Category.new(name: "Пиццы")
      expect(category).not_to be_valid
      expect(category.errors[:slug]).to include("не может быть пустым")
    end

    it "is invalid with duplicate slug" do
      Category.create!(name: "Пиццы", slug: "pizzas")
      dup = Category.new(name: "Суши", slug: "pizzas")
      expect(dup).not_to be_valid
      expect(dup.errors[:slug]).to include("уже используется")
    end

    it "is invalid if name is too long" do
      category = Category.new(name: "a" * 256, slug: "long-name")
      expect(category).not_to be_valid
    end

    it "is invalid if slug is too long" do
      category = Category.new(name: "Пиццы", slug: "a" * 256)
      expect(category).not_to be_valid
    end

    it "is invalid if description is too long" do
      category = Category.new(name: "Пиццы", slug: "pizzas", description: "a" * 2001)
      expect(category).not_to be_valid
    end

    it "is valid with all required attributes" do
      category = Category.new(name: "Пиццы", slug: "pizzas", description: "Вкусные пиццы")
      expect(category).to be_valid
    end
  end
end
