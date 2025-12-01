class OrdersController < ApplicationController
  before_action :authenticate_user!
  
  def history
    # Загружаем ВСЕ бронирования пользователя со всеми связанными данными
    # .includes(:order) теперь будет работать правильно
    @all_bookings = current_user.bookings
                                     .includes(:order, :seats, :booking_seats, cart: { cart_items: :dish }, order: { order_items: :dish })
                                     .order(created_at: :desc)

    # Разделяем на активные и завершенные для отображения в разных секциях (если нужно)
    @active_bookings = @all_bookings.select { |b| ['confirmed', 'pending'].include?(b.status) && b.ends_at > Time.current }
    @completed_bookings = @all_bookings.select { |b| ['completed', 'cancelled'].include?(b.status) || b.ends_at <= Time.current }
  end

  def show
    # Сначала пытаемся найти заказ по ID
    @order = current_user.orders.includes(:order_items, :booking).find_by(id: params[:id])

    if @order
      # Если заказ найден, получаем связанное бронирование
      @booking = @order.booking
      @order_items = @order.order_items.includes(:dish)
    else
      # Если заказ не найден, ищем бронирование по ID
      @booking = current_user.bookings.includes(:order, seats: :table, booking_seats: :seat).find(params[:id])
      
      # Если бронирование найдено, получаем связанный с ним заказ (если он есть)
      @order = @booking.order
      @order_items = @order.order_items.includes(:dish) if @order
    end

    # Если ни заказ, ни бронирование не найдены, вызываем ошибку
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

  # Вспомогательные методы для статусов, чтобы они были доступны в этом контроллере
  def status_badge_class(status)
    case status
    when 'confirmed' then 'badge-success'
    when 'completed' then 'badge-success'
    when 'pending' then 'badge-warning'
    when 'cancelled' then 'badge-error'
    else 'badge-neutral'
    end
  end

  def status_in_russian(status)
    case status
    when 'confirmed' then 'Подтверждено'
    when 'completed' then 'Завершено'
    when 'pending' then 'Ожидает'
    when 'cancelled' then 'Отменено'
    else status
    end
  end

  def generate_special_instructions(cart_item)
    # Так как мы вызываем этот метод внутри цикла с .includes(:cart_item_ingredients),
    # все cart_item_ingredients уже загружены в память. Дополнительных запросов к БД не будет.
    item_ingredients = cart_item.cart_item_ingredients

    # Разделяем ингредиенты на добавленные и удаленные прямо в памяти
    added_names = item_ingredients.select { |cii| !cii.default_in_dish && cii.included? }
                                  .map { |cii| cii.ingredient.name }

    removed_names = item_ingredients.select { |cii| cii.default_in_dish && !cii.included? }
                                   .map { |cii| cii.ingredient.name }

    instructions = []
    if added_names.any?
      # Формируем строку "Добавки: ..." с точным форматом
      instructions << "Добавки: #{added_names.join(', ')}"
    end

    if removed_names.any?
      # Формируем строку "Без: ..."
      instructions << "Без: #{removed_names.join(', ')}"
    end

    # Соединяем части через '; ', как в вашем примере
    instructions.any? ? instructions.join('; ') : nil
  end

  # Делаем метод доступным в представлении
  helper_method :status_badge_class, :status_in_russian, :generate_special_instructions
end
