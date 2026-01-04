
class DishesController < ApplicationController
  def show
    # Ищем блюдо по slug для SEO-оптимизированных URL
    @dish = Dish.find_by(slug: params[:slug])

    # Если блюдо не найдено или удалено, перенаправляем на меню
    return redirect_to menu_path, alert: "Блюдо не найдено" unless @dish

    @category = @dish.category
    # Жаркая загрузка ингредиентов для избежания N+1 запросов
    @ingredients = @dish.dish_ingredients.includes(:ingredient)

    # Разделяем ингредиенты на стандартные (в блюде) и дополнительные (опциональные)
    # для корректного отображения UI и расчета стоимости
    if @ingredients.present?
      @default_ingredients = @ingredients.where(default: true)
      @new_ingredients = @ingredients.where(default: false)
    else
      @default_ingredients = []
      @new_ingredients = []
    end
  end

  def index
    # Получаем текущую категорию
    @category = Category.active.find_by!(slug: params[:slug])
    # Загружаем другие категории для навигационного меню (боковая панель)
    @other_categories = Category.active.where.not(id: @category.id).order(:name)

    if @category.dishes.active.exists?
      # Первичная загрузка: только первые 12 блюд для быстрого рендеринга (Infinite Scroll)
      @dishes = @category.dishes.active.order(created_at: :desc).limit(12)

      # Инициализируем состояние подгрузки для JS-контроллера
      @loaded_categories = [ @category.id ]
      @category_offsets = { @category.id => 12 }
      @has_more_dishes = @category.dishes.active.count > 12
    else
      # Обработка пустой категории
      @dishes = []
      @loaded_categories = [ @category.id ]
      @category_offsets = { @category.id => 0 }
      @has_more_dishes = false
      @empty_category = true
    end
  end

  def load_more
    # Восстанавливаем состояние подгрузки из параметров запроса (от JS)
    loaded_category_ids = params[:loaded_categories]&.split(",")&.map(&:to_i) || []
    category_offsets = params[:category_offsets]&.split(",")&.map { |pair| pair.split(":").map(&:to_i) }&.to_h || {}
    current_category_id = params[:current_category_id]&.to_i

    # Определяем текущую категорию (если ID не передан, берем из slug)
    if current_category_id.zero?
      @category = Category.active.find_by!(slug: params[:slug])
      current_category_id = @category.id
      loaded_category_ids << current_category_id unless loaded_category_ids.include?(current_category_id)
    else
      @category = Category.find(current_category_id)
    end

    # Получаем следующую порцию блюд, пропуская уже загруженные (offset)
    current_offset = category_offsets[current_category_id] || 0
    dishes = @category.dishes.active
                        .order(created_at: :desc)
                        .offset(current_offset)
                        .limit(12)

    @new_category = false
    @empty_category = false

    if dishes.empty?
      # Если список блюд в текущей категории закончился, проверяем, есть ли еще блюда
      unless @category.dishes.active.exists?
        @empty_category = true
        @dishes = []
      else
        # Логика автоперехода: если в текущей категории все просмотрено, ищем следующую непустую категорию
        next_category = Category.active
                                .where.not(id: loaded_category_ids)
                                .order(:name)
                                .find { |cat| cat.dishes.active.exists? }

        if next_category
          # Переключаемся на новую категорию
          @category = next_category
          dishes = @category.dishes.active.order(created_at: :desc).limit(12)
          current_category_id = next_category.id
          loaded_category_ids << next_category.id
          category_offsets[next_category.id] = 12
          @new_category = true
          @empty_category = false unless dishes.empty?
        end
      end
    else
      # Обновляем смещение (offset) для текущей категории для следующего запроса
      category_offsets[current_category_id] = current_offset + 12
    end

    @dishes = dishes

    # Рендерим частичный шаблон для вставки в DOM без перезагрузки страницы (Turbo/AJAX)
    render partial: "dishes/dish", collection: @dishes,
           locals: {
             category: @category,
             new_category: @new_category,
             empty_category: @empty_category,
             current_category_id: current_category_id,
             loaded_categories: loaded_category_ids,
             category_offsets: category_offsets
           },
           formats: [ :html ]
  end
end
