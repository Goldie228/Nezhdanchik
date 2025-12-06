class ManagerController < ApplicationController
  before_action :authenticate_user!
  before_action :require_manager_role
  before_action :set_date_range, only: [:calendar, :tables_view]
  before_action :set_booking, only: [:show, :edit, :update, :destroy]

  TABLE_COORDS = [
    { id: 1, x_percent: 38.5, y_percent: 38.5, width_percent: 10, height_percent: 5 },
    { id: 2, x_percent: 54.5, y_percent: 7.5, width_percent: 21, height_percent: 5 },
    { id: 3, x_percent: 82.5, y_percent: 38.5, width_percent: 10, height_percent: 5 },
    { id: 4, x_percent: 54, y_percent: 68.5, width_percent: 21, height_percent: 5 }
  ].freeze

  SEATS_COORDS = [
    { id: 1,  x_percent: 37,   y_percent: 29   },
    { id: 2,  x_percent: 46.4, y_percent: 29   },
    { id: 3,  x_percent: 37,   y_percent: 47.5 },
    { id: 4,  x_percent: 46.4, y_percent: 47.5 },
    { id: 5,  x_percent: 47,   y_percent: 8    },
    { id: 6,  x_percent: 51,   y_percent: 17.8 },
    { id: 7,  x_percent: 59.8, y_percent: 17.8 },
    { id: 8,  x_percent: 68.8, y_percent: 17.8 },
    { id: 9,  x_percent: 78,   y_percent: 17.8 },
    { id: 10, x_percent: 81.1, y_percent: 7.9  },
    { id: 11, x_percent: 81,   y_percent: 29.5 },
    { id: 12, x_percent: 90.5, y_percent: 29.5 },
    { id: 13, x_percent: 81,   y_percent: 48   },
    { id: 14, x_percent: 90.5, y_percent: 48   },
    { id: 15, x_percent: 81,   y_percent: 69.0 },
    { id: 16, x_percent: 75.0, y_percent: 59.0 },
    { id: 17, x_percent: 65.9, y_percent: 59.0 },
    { id: 18, x_percent: 57.8, y_percent: 59.0 },
    { id: 19, x_percent: 50.0, y_percent: 59.0 },
    { id: 20, x_percent: 46.3, y_percent: 69.0 }
  ].freeze

  def tables_view
    @tables = Table.includes(:seats).active
    @current_bookings = Booking.includes(:user, :seats, :order)
                               .where(status: ['pending', 'confirmed'])
                               .where('starts_at <= ? AND ends_at >= ?', Time.current, Time.current)
    
    @today_bookings = Booking.includes(:user, :seats, :order)
                             .where(status: ['pending', 'confirmed'])
                             .where('starts_at >= ? AND starts_at <= ?', Date.current.beginning_of_day, Date.current.end_of_day)
                             .order(starts_at: :asc)
    
    # Получаем все места для отображения на плане
    @seats = Seat.includes(:table).all
    
    # Передаем константы в представление
    @table_coords = TABLE_COORDS
    @seat_coords = SEATS_COORDS
  end
  def dashboard
    @active_bookings = get_active_bookings
    @statuses = get_statuses_list
    @today_bookings = Booking.includes(:user, :seats, :order)
                             .where(status: ['pending', 'confirmed'])
                             .where('starts_at >= ? AND starts_at <= ?', Date.current.beginning_of_day, Date.current.end_of_day)
                             .order(starts_at: :asc)
    
    @tables = Table.includes(:seats).active
    @current_bookings = Booking.includes(:user, :seats, :order)
                               .where(status: ['pending', 'confirmed'])
                               .where('starts_at <= ? AND ends_at >= ?', Time.current, Time.current)
    @upcoming_bookings = Booking.includes(:user, :seats, :order)
                               .where(status: ['pending', 'confirmed'])
                               .where('starts_at > ? AND starts_at <= ?', Time.current, Time.current + 7.days)
                               .order(starts_at: :asc)
                               .limit(10)
  end

  def calendar
    @bookings = Booking.includes(:user, :seats, :order)
                      .where(status: ['pending', 'confirmed'])
                      .where('starts_at >= ? AND starts_at <= ?', @start_date, @end_date)
                      .order(starts_at: :asc)
    
    @tables = Table.includes(:seats).active
  end

  def tables_view
    @tables = Table.includes(:seats).active
    @current_bookings = Booking.includes(:user, :seats, :order)
                               .where(status: ['pending', 'confirmed'])
                               .where('starts_at <= ? AND ends_at >= ?', Time.current, Time.current)
    
    @today_bookings = Booking.includes(:user, :seats, :order)
                             .where(status: ['pending', 'confirmed'])
                             .where('starts_at >= ? AND starts_at <= ?', Date.current.beginning_of_day, Date.current.end_of_day)
                             .order(starts_at: :asc)
    
    # Получаем все места для отображения на плане
    @seats = Seat.includes(:table).all
  end

  def show
    @order_items = @booking.order&.order_items&.includes(:dish) || []
    @special_requests = @booking.special_requests
    @statuses = get_statuses_list
  end

  def edit
    # @booking уже установлен в before_action
  end

  def update
    if @booking.update(booking_params)
      redirect_to manager_booking_path(@booking), notice: "Бронирование успешно обновлено"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @booking.update(status: 'cancelled')
    redirect_to manager_bookings_path, notice: "Бронирование отменено"
  end

  def bookings
    @bookings = Booking.includes(:user, :seats, :order)
                      .where(status: ['pending', 'confirmed'])
                      .order(starts_at: :desc)
                      .page(params[:page])
                      .per(20)
    
    @statuses = get_statuses_list
  end

  def update_status
    booking = Booking.find(params[:id])
    
    if booking.update(status: params[:status])
      render json: { success: true, message: "Статус обновлен" }
    else
      render json: { success: false, message: "Ошибка при обновлении статуса" }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, message: "Бронирование не найдено" }, status: :not_found
  end

  def refresh_orders
    # Получаем обновленные данные
    @active_bookings = get_active_bookings
    @statuses = get_statuses_list
    
    # Возвращаем обновленный HTML для списка бронирований
    render partial: 'bookings_list', locals: { active_bookings: @active_bookings, statuses: @statuses }, layout: false
  rescue => e
    Rails.logger.error "Error in refresh_bookings: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { success: false, message: "Ошибка при обновлении данных: #{e.message}" }, status: :internal_server_error
  end

  private

  def set_booking
    @booking = Booking.includes(:user, :seats, :order, :booking_seats).find(params[:id])
  end

  def set_date_range
    if params[:date].present?
      @selected_date = Date.parse(params[:date])
    else
      @selected_date = Date.current
    end
    
    @start_date = @selected_date.beginning_of_day
    @end_date = @selected_date.end_of_day
  end

  def booking_params
    params.require(:booking).permit(:special_requests, :starts_at, :ends_at)
  end

  def get_active_bookings
    # Ищем актуальные бронирования с активными статусами
    Booking.includes(:order, :booking_seats, :seats, :user)
        .where(status: ['pending', 'confirmed'])
        .where('ends_at > ?', Time.current)
        .order(created_at: :desc)
  end

  def get_statuses_list
    [
      { value: "pending", text: "Ожидает", color: "badge-warning" },
      { value: "confirmed", text: "Подтверждено", color: "badge-info" },
      { value: "completed", text: "Завершено", color: "badge-success" },
      { value: "cancelled", text: "Отменено", color: "badge-neutral" }
    ]
  end

  # Метод форматирования номера телефона
  def format_phone_number(phone)
    # Удаляем все нецифровые символы
    cleaned = phone.gsub(/\D/, '')
    
    # Проверяем, что номер начинается с +375 (Беларусь)
    if cleaned.start_with?('375') && cleaned.length == 12
      country_code = "+375"
      operator_code = cleaned[0..1]
      first_part = cleaned[2..4]
      second_part = cleaned[5..7]
      third_part = cleaned[8..10]
      
      return "#{country_code} (#{operator_code}) #{first_part}-#{second_part}-#{third_part}"
    end
    
    # Если формат не соответствует ожидаемому, возвращаем как есть
    phone
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
  helper_method :generate_special_instructions
  helper_method :get_statuses_list
  helper_method :format_phone_number

  # ВОССТАНОВЛЕНА ИСХОДНАЯ ЛОГИКА
  def require_manager_role
    if current_user&.role&.to_s.in?(["2", "3"])
      redirect_to root_path, alert: "Доступ запрещен"
    end
  end
end
