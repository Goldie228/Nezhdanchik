
class CategoriesController < ApplicationController
  def index
    # Загружаем только активные категории, в которых есть хотя бы одно активное блюдо.
    # distinct обязателен, так как JOIN создает дубликаты записей для каждого блюда.
    @categories = Category
      .joins(:dishes)
      .where(active: true, dishes: { active: true })
      .distinct
      .order(created_at: :desc)
  end
end
