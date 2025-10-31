require "rails_helper"

RSpec.describe CategoriesController, type: :request do
  describe "GET /menu" do
    let!(:active_category) do
      Category.create!(name: "Active", slug: "active-#{SecureRandom.hex(4)}", active: true)
    end
    let!(:inactive_category) do
      Category.create!(name: "Inactive", slug: "inactive-#{SecureRandom.hex(4)}", active: false)
    end

    before do
      Dish.create!(title: "Active Dish", slug: "active-dish-#{SecureRandom.hex(4)}", price: 5, active: true, category: active_category)
      Dish.create!(title: "Inactive Dish", slug: "inactive-dish-#{SecureRandom.hex(4)}", price: 5, active: false, category: active_category)
    end

    it "renders only active categories with active dishes" do
      get menu_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(active_category.name)
      expect(response.body).not_to include(inactive_category.name)
    end

    it "orders categories by created_at desc" do
      newer = Category.create!(name: "Newer", slug: "newer-#{SecureRandom.hex(4)}", active: true, created_at: 1.day.from_now)
      Dish.create!(title: "Newer Dish", slug: "newer-dish-#{SecureRandom.hex(4)}", price: 7, active: true, category: newer)

      get menu_path
      expect(response.body.index(newer.name)).to be < response.body.index(active_category.name)
    end
  end
end
