
class OrdersController < ApplicationController
  before_action :authenticate_user!

  def history
    # Агрессивная подгрузка (includes) всех связанных данных для рендеринга истории без N+1 запросов
    @all_bookings = current_user.bookings
                                     .includes(:order, :seats, :booking_seats, cart: { cart_items: :dish }, order: { order_items: :dish })
                                     .order(created_at: :desc)

    # Разделяем бронирования на активные и завершенные.
    # Используем Ruby select для гибкой проверки по времени (ends_at), что сложнее сделать чистым SQL.
    @active_bookings = @all_bookings.select { |b| [ "confirmed", "pending" ].include?(b.status) && b.ends_at > Time.current }
    @completed_bookings = @all_bookings.select { |b| [ "completed", "cancelled" ].include?(b.status) || b.ends_at <= Time.current }
  end

  def show
    # Сначала ищем заказ напрямую
    @order = current_user.orders.includes(:order_items, :booking).find_by(id: params[:id])

    if @order
      @booking = @order.booking
      @order_items = @order.order_items.includes(:dish)
    else
      # Fallback: если заказ не найден (например, еще не оплачен или создан), ищем бронирование
      # Это позволяет использовать один маршрут /orders/:id для просмотра сущностей на разных стадиях
      @booking = current_user.bookings.includes(:order, seats: :table, booking_seats: :seat).find(params[:id])

      @order = @booking.order
      @order_items = @order.order_items.includes(:dish) if @order
    end

    # Если ни заказ, ни бронь не найдены — выбрасываем 404
    unless @order || @booking
      raise ActiveRecord::RecordNotFound
    end
  end

  # Функционал "Повторить заказ" — перенос товаров из старого заказа в текущую корзину
  def repeat
    order = current_user.orders.find(params[:id])

    cart = Cart.for_user!(current_user)
    # Полная очистка корзины перед наполнением, чтобы избежать смешивания товаров
    cart.cart_items.destroy_all

    # Копируем только блюдо и количество. Примечание: кастомные ингредиенты не переносятся,
    # так как OrderItem хранит их в текстовом виде, а CartItem требует пересоздания связей.
    order.order_items.each do |item|
      cart.cart_items.create!(
        dish: item.dish,
        quantity: item.quantity
      )
    end

    redirect_to cart_path, notice: "Товары из заказа добавлены в корзину"
  end

  private

  # Возвращает CSS-класс в зависимости от статуса для цветовой индикации (DaisyUI)
  def status_badge_class(status)
    case status
    when "confirmed" then "badge-success"
    when "completed" then "badge-success"
    when "pending" then "badge-warning"
    when "cancelled" then "badge-error"
    else "badge-neutral"
    end
  end

  # Перевод статусов заказа на русский язык
  def status_in_russian(status)
    case status
    when "confirmed" then "Подтверждено"
    when "completed" then "Завершено"
    when "pending" then "Ожидает"
    when "cancelled" then "Отменено"
    else status
    end
  end

  # Вспомогательный метод для восстановления состава блюда из данных корзины
  # (используется во View для отображения истории состава)
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

  # Экспорт методов для использования в представлениях (Views)
  helper_method :status_badge_class, :status_in_russian, :generate_special_instructions
end
