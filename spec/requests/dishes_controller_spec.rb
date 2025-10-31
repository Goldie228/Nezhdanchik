require "rails_helper"

RSpec.describe DishesController, type: :request do
  let!(:category) { Category.create!(name: "Pizza", slug: "pizza", active: true) }
  let!(:other_category) { Category.create!(name: "Sushi", slug: "sushi", active: true) }

  describe "GET /menu/:slug" do
    context "when category has active dishes" do
      before do
        15.times do |i|
          Dish.create!(title: "Dish #{i}", slug: "dish-#{i}-#{SecureRandom.hex(2)}", price: 10, active: true, category: category)
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
        Dish.create!(title: "Dish #{i}", slug: "dish-#{i}-#{SecureRandom.hex(2)}", price: 10, active: true, category: category)
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
        Dish.create!(title: "Other Dish #{i}", slug: "other-dish-#{i}-#{SecureRandom.hex(2)}", price: 12, active: true, category: other_category)
      end

      get load_more_dishes_path(slug: category.slug),
          params: { current_category_id: category.id,
                    category_offsets: "#{category.id}:20",
                    loaded_categories: category.id.to_s }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(other_category.name)
    end
  end
end
