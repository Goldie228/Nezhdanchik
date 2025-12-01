class CartController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart
  before_action :set_cart_item, only: [ :update, :remove ]

  def show
    prepare_cart_data
  end

  def add
    dish = Dish.find(params[:dish_id])
    selected, removed = normalize_ingredient_params(params)

    existing_cart_item = find_existing_cart_item(dish, selected, removed)

    if existing_cart_item
      existing_cart_item.increment!(:quantity)
      @cart_item = existing_cart_item
    else
      CartItem.transaction do
        cart_item = @cart.cart_items.create!(dish: dish)
        cart_item.reload

        apply_removed_ingredients!(cart_item, removed) if removed.any?
        apply_selected_ingredients!(cart_item, selected) if selected.any?

        @cart_item = cart_item
      end
    end

    respond_to do |format|
      format.json do
        render json: {
          quantity: get_cart_item_quantity(dish, selected, removed),
          in_cart: true
        }
      end

      format.html { redirect_to cart_path }
      format.turbo_stream do
        # Готовим актуальные данные для Turbo Stream ответа
        @cart_item = @cart_item.reload if @cart_item&.persisted?
        prepare_cart_data
        render "update_cart"
      end
    end
  end

  def cart_info
    dish = Dish.find(params[:dish_id])
    selected, removed = normalize_ingredient_params(params)

    quantity = get_cart_item_quantity(dish, selected, removed)

    render json: { quantity: quantity, in_cart: quantity > 0 }
  end

  def increase
    dish = Dish.find(params[:dish_id])
    selected, removed = normalize_ingredient_params(params)

    existing_cart_item = find_existing_cart_item(dish, selected, removed)

    if existing_cart_item
      existing_cart_item.increment!(:quantity)
      @cart_item = existing_cart_item
    else
      CartItem.transaction do
        cart_item = @cart.cart_items.create!(dish: dish)
        cart_item.reload

        apply_removed_ingredients!(cart_item, removed) if removed.any?
        apply_selected_ingredients!(cart_item, selected) if selected.any?

        @cart_item = cart_item
      end
    end

    respond_to do |format|
      format.json do
        render json: {
          quantity: get_cart_item_quantity(dish, selected, removed),
          in_cart: true
        }
      end
      format.turbo_stream do
        @cart_item = @cart_item.reload if @cart_item&.persisted?
        prepare_cart_data
      end
    end
  end

  def decrease
    dish = Dish.find(params[:dish_id])
    selected, removed = normalize_ingredient_params(params)

    existing_cart_item = find_existing_cart_item(dish, selected, removed)

    if existing_cart_item
      if existing_cart_item.quantity > 1
        existing_cart_item.decrement!(:quantity)
      else
        existing_cart_item.destroy
      end
    end

    respond_to do |format|
      format.json do
        render json: {
          quantity: get_cart_item_quantity(dish, selected, removed),
          in_cart: get_cart_item_quantity(dish, selected, removed) > 0
        }
      end
      format.turbo_stream do
        prepare_cart_data
        render "update_cart"
      end
    end
  end

  def update
    if params[:quantity_action] == "increase"
      @cart_item.increment!(:quantity)
    elsif params[:quantity_action] == "decrease"
      if @cart_item.quantity > 1
        @cart_item.decrement!(:quantity)
      else
        @cart_item.destroy
      end
    elsif params[:quantity].present?
      @cart_item.update(quantity: params[:quantity])
    end

    respond_to do |format|
      format.html { redirect_to cart_path, notice: "Корзина обновлена" }
      format.json { render json: { success: true } }
      format.turbo_stream do
        # Перезагружаем объект, чтобы получить актуальное состояние (quantity, persisted?)
        @cart_item = @cart.cart_items.find_by(id: params[:id]) if @cart_item.destroyed?
        @cart_item.reload if @cart_item&.persisted?

        # Готовим актуальные данные для всего ответа
        prepare_cart_data
      end
    end
  end

  def remove
    @cart_item.destroy

    respond_to do |format|
      format.html { redirect_to cart_path, notice: "Товар удален из корзины" }
      format.json { render json: { success: true } }
      format.turbo_stream do
        # Готовим данные для обновления итогов после удаления
        prepare_cart_data
        render "update_cart"
      end
    end
  end

  def clear
    @cart.cart_items.destroy_all
    respond_to do |format|
      format.html { redirect_to cart_path, notice: "Корзина очищена" }
      format.turbo_stream { redirect_to cart_path }
    end
  end

  private

  # Этот метод теперь только устанавливает корзину.
  def set_cart
    @cart = Cart.for_user!(current_user)
  end

  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  end

  # Централизованный метод для подготовки данных о корзине.
  # Вызывается из всех действий, которые рендерят данные.
  def prepare_cart_data
    @cart_items = @cart.cart_items.includes(:dish, cart_item_ingredients: :ingredient).active
    @total_price = @cart.total_cents / 100.0
    @total_items = @cart.total_items_count
  end

  def normalize_ingredient_params(params_source)
    selected_raw = params_source[:selected_ingredient_ids]
    removed_raw  = params_source[:removed_ingredient_ids]

    selected = case selected_raw
    when String then selected_raw.split(",")
    when Array  then selected_raw
    when nil    then []
    else Array(selected_raw)
    end.map(&:to_i).sort

    removed = case removed_raw
    when String then removed_raw.split(",")
    when Array  then removed_raw
    when nil    then []
    else Array(removed_raw)
    end.map(&:to_i).sort

    [ selected, removed ]
  end

  def find_existing_cart_item(dish, selected_ingredient_ids, removed_ingredient_ids)
    @cart.cart_items.where(dish: dish).active.detect do |item|
      item.matches_composition?(selected_ingredient_ids, removed_ingredient_ids)
    end
  end

  def get_cart_item_quantity(dish, selected_ingredient_ids, removed_ingredient_ids)
    existing = find_existing_cart_item(dish, selected_ingredient_ids, removed_ingredient_ids)
    existing ? existing.quantity : 0
  end

  def apply_removed_ingredients!(cart_item, removed_ids)
    return if removed_ids.blank?

    cart_item.cart_item_ingredients
             .where(ingredient_id: removed_ids, default_in_dish: true)
             .find_each do |cii|
               cii.update!(included: false)
             end
  end

  def apply_selected_ingredients!(cart_item, selected_ids)
    return if selected_ids.blank?

    Ingredient.where(id: selected_ids).find_each do |ingredient|
      cii = cart_item.cart_item_ingredients.find_by(ingredient_id: ingredient.id)

      if cii.nil?
        cart_item.cart_item_ingredients.create!(
          ingredient: ingredient,
          included: true,
          default_in_dish: false,
          price: (ingredient.price.to_d * 100).to_i
        )
      else
        cii.update!(included: true) unless cii.included
      end
    end
  end
end
