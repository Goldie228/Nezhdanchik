class DishesController < ApplicationController
  def show
    @dish = Dish.find_by(slug: params[:slug])

    return redirect_to menu_path, alert: "Блюдо не найдено" unless @dish

    @category = @dish.category
    @ingredients = @dish.dish_ingredients.includes(:ingredient)

    if @ingredients.present?
      @default_ingredients = @ingredients.where(default: true)
      @new_ingredients = @ingredients.where(default: false)
    else
      @default_ingredients = []
      @new_ingredients = []
    end
  end

  def index
    @category = Category.active.find_by!(slug: params[:slug])
    @other_categories = Category.active.where.not(id: @category.id).order(:name)

    if @category.dishes.active.exists?
      @dishes = @category.dishes.active.order(created_at: :desc).limit(12)
      @loaded_categories = [ @category.id ]
      @category_offsets = { @category.id => 12 }
      @has_more_dishes = @category.dishes.active.count > 12
    else
      @dishes = []
      @loaded_categories = [ @category.id ]
      @category_offsets = { @category.id => 0 }
      @has_more_dishes = false
      @empty_category = true
    end
  end

  def load_more
    loaded_category_ids = params[:loaded_categories]&.split(",")&.map(&:to_i) || []
    category_offsets = params[:category_offsets]&.split(",")&.map { |pair| pair.split(":").map(&:to_i) }&.to_h || {}
    current_category_id = params[:current_category_id]&.to_i

    if current_category_id.zero?
      @category = Category.active.find_by!(slug: params[:slug])
      current_category_id = @category.id
      loaded_category_ids << current_category_id unless loaded_category_ids.include?(current_category_id)
    else
      @category = Category.find(current_category_id)
    end

    current_offset = category_offsets[current_category_id] || 0
    dishes = @category.dishes.active
                        .order(created_at: :desc)
                        .offset(current_offset)
                        .limit(12)

    @new_category = false
    @empty_category = false

    if dishes.empty?
      unless @category.dishes.active.exists?
        @empty_category = true
        @dishes = []
      else
        next_category = Category.active
                                .where.not(id: loaded_category_ids)
                                .order(:name)
                                .find { |cat| cat.dishes.active.exists? }

        if next_category
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
      category_offsets[current_category_id] = current_offset + 12
    end

    @dishes = dishes

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
