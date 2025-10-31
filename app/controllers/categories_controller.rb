class CategoriesController < ApplicationController
  def index
    @categories = Category
      .joins(:dishes)
      .where(active: true, dishes: { active: true })
      .distinct
      .order(created_at: :desc)
  end
end
