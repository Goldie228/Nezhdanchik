class OrdersController < ApplicationController
  before_action :authenticate_user!

  def history
    @all_bookings = current_user.bookings
                                     .includes(:order, :seats, :booking_seats, cart: { cart_items: :dish }, order: { order_items: :dish })
                                     .order(created_at: :desc)

    @active_bookings = @all_bookings.select { |b| [ "confirmed", "pending" ].include?(b.status) && b.ends_at > Time.current }
    @completed_bookings = @all_bookings.select { |b| [ "completed", "cancelled" ].include?(b.status) || b.ends_at <= Time.current }
  end

  def show
    @order = current_user.orders.includes(:order_items, :booking).find_by(id: params[:id])

    if @order
      @booking = @order.booking
      @order_items = @order.order_items.includes(:dish)
    else
      @booking = current_user.bookings.includes(:order, seats: :table, booking_seats: :seat).find(params[:id])

      @order = @booking.order
      @order_items = @order.order_items.includes(:dish) if @order
    end

    unless @order || @booking
      raise ActiveRecord::RecordNotFound
    end
  end

  def repeat
    order = current_user.orders.find(params[:id])

    cart = Cart.for_user!(current_user)
    cart.cart_items.destroy_all

    order.order_items.each do |item|
      cart.cart_items.create!(
        dish: item.dish,
        quantity: item.quantity
      )
    end

    redirect_to cart_path, notice: "Товары из заказа добавлены в корзину"
  end

  private

  def status_badge_class(status)
    case status
    when "confirmed" then "badge-success"
    when "completed" then "badge-success"
    when "pending" then "badge-warning"
    when "cancelled" then "badge-error"
    else "badge-neutral"
    end
  end

  def status_in_russian(status)
    case status
    when "confirmed" then "Подтверждено"
    when "completed" then "Завершено"
    when "pending" then "Ожидает"
    when "cancelled" then "Отменено"
    else status
    end
  end

  def generate_special_instructions(cart_item)
    item_ingredients = cart_item.cart_item_ingredients

    added_names = item_ingredients.select { |cii| !cii.default_in_dish && cii.included? }
                                  .map { |cii| cii.ingredient.name }

    removed_names = item_ingredients.select { |cii| cii.default_in_dish && !cii.included? }
                                   .map { |cii| cii.ingredient.name }

    instructions = []
    if added_names.any?
      instructions << "Добавки: #{added_names.join(', ')}"
    end

    if removed_names.any?
      instructions << "Без: #{removed_names.join(', ')}"
    end

    instructions.any? ? instructions.join("; ") : nil
  end

  helper_method :status_badge_class, :status_in_russian, :generate_special_instructions
end
