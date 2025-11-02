require "rails_helper"

RSpec.describe DishesController, type: :request do
  let!(:category) { Category.create!(name: "Pizza", slug: "pizza", active: true) }
  let!(:other_category) { Category.create!(name: "Sushi", slug: "sushi", active: true) }

  describe "GET /menu/:slug" do
    context "when category has active dishes" do
      before do
        15.times do |i|
          Dish.create!(title: "Dish #{i}", slug: "dish-#{i}-#{SecureRandom.hex(2)}",
                       price: 10, active: true, category: category)
        end
      end

      it "renders dishes list with pagination" do
        get category_dishes_path(slug: category.slug)
        expect(response).to have_http_status(:ok)
        expect(response.body.scan(/Dish/).count).to eq(12)
      end
    end

    context "when category has no active dishes" do
      it "renders empty state" do
        get category_dishes_path(slug: category.slug)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(category.name)
        expect(response.body).not_to include("Dish")
      end
    end
  end

  describe "GET /more_dishes/:slug" do
    before do
      15.times do |i|
        Dish.create!(title: "Dish #{i}", slug: "dish-#{i}-#{SecureRandom.hex(2)}",
                     price: 10, active: true, category: category)
      end
    end

    it "loads the next batch of dishes" do
      get load_more_dishes_path(slug: category.slug),
          params: { current_category_id: category.id,
                    category_offsets: "#{category.id}:12",
                    loaded_categories: category.id.to_s }

      expect(response).to have_http_status(:ok)
      expect(response.body.scan(/Dish/).count).to eq(3)
    end

    it "switches to next category if current exhausted" do
      5.times do |i|
        Dish.create!(title: "Other Dish #{i}", slug: "other-dish-#{i}-#{SecureRandom.hex(2)}",
                     price: 12, active: true, category: other_category)
      end

      get load_more_dishes_path(slug: category.slug),
          params: { current_category_id: category.id,
                    category_offsets: "#{category.id}:20",
                    loaded_categories: category.id.to_s }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(other_category.name)
    end
  end

  describe "GET /menu/:slug/order" do
    let!(:dish) { Dish.create!(title: "Margherita", slug: "margherita", price: 15, active: true, category: category) }
    let!(:nutrition) { Nutrition.create!(dish: dish, proteins: 10, fats: 5, carbohydrates: 20) }
    let!(:ingredient) { Ingredient.create!(name: "Cheese") }
    let!(:ingredient_nutrition) { Nutrition.create!(ingredient: ingredient, proteins: 3, fats: 4, carbohydrates: 1) }
    let!(:dish_ingredient) { DishIngredient.create!(dish: dish, ingredient: ingredient, default: true) }

    it "renders dish page with nutrition info" do
      get dish_path(slug: dish.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Margherita")
      expect(response.body).to include("Белки")
      expect(response.body).to include("10")
      expect(response.body).to include("5")
      expect(response.body).to include("20")
    end

    it "renders ingredients with nutrition info" do
      get dish_path(slug: dish.slug)

      expect(response.body).to include("Cheese")
      expect(response.body).to include("3")
      expect(response.body).to include("4")
      expect(response.body).to include("1")
    end

    it "redirects if dish not found" do
      get dish_path(slug: "unknown")
      expect(response).to redirect_to(menu_path)
      follow_redirect!
      expect(response.body).to include("Блюдо не найдено")
    end
  end
end
