
class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reservation, only: [ :details, :update, :cancel ]

  STATUSES = {
    available: "available",
    reserved: "reserved",
    occupied: "occupied"
  }.freeze

  STATUS_CLASSES = {
    available: "bg-success",
    reserved:  "bg-warning",
    occupied: "bg-error"
  }.freeze

  BOOKING_STATUS_CLASSES = {
    pending: "badge-warning",
    confirmed: "badge-success",
    cancelled: "badge-error",
    completed: "badge-info"
  }.freeze

  SEATS_COORDS = [
    { num: 1,  x_percent: 37,   y_percent: 29   },
    { num: 2,  x_percent: 46.4, y_percent: 29   },
    { num: 3,  x_percent: 37,   y_percent: 47.5 },
    { num: 4,  x_percent: 46.4, y_percent: 47.5 },
    { num: 5,  x_percent: 47,   y_percent: 8    },
    { num: 6,  x_percent: 51,   y_percent: 17.8 },
    { num: 7,  x_percent: 59.8, y_percent: 17.8 },
    { num: 8,  x_percent: 68.8, y_percent: 17.8 },
    { num: 9,  x_percent: 78,   y_percent: 17.8 },
    { num: 10, x_percent: 81.1, y_percent: 7.9  },
    { num: 11, x_percent: 81,   y_percent: 29.5 },
    { num: 12, x_percent: 90.5, y_percent: 29.5 },
    { num: 13, x_percent: 81,   y_percent: 48   },
    { num: 14, x_percent: 90.5, y_percent: 48   },
    { num: 15, x_percent: 81,   y_percent: 69.0 },
    { num: 16, x_percent: 75.0, y_percent: 59.0 },
    { num: 17, x_percent: 65.9, y_percent: 59.0 },
    { num: 18, x_percent: 57.8, y_percent: 59.0 },
    { num: 19, x_percent: 50.0, y_percent: 59.0 },
    { num: 20, x_percent: 46.3, y_percent: 69.0 }
  ]

  TABLE_COORDS = [
    { num: 1, x_percent: 38.5, y_percent: 38.5, width_percent: 10, height_percent: 5 },
    { num: 2, x_percent: 54.5, y_percent: 7.5,  width_percent: 21, height_percent: 5 },
    { num: 3, x_percent: 82.5, y_percent: 38.5, width_percent: 10, height_percent: 5 },
    { num: 4, x_percent: 54,   y_percent: 68.5, width_percent: 21, height_percent: 5 }
  ]

  def show
    active_booking = Booking.where(user: current_user, status: [ "confirmed", "pending" ])
                           .where("ends_at > ?", Time.current)
                           .first

    if active_booking
      redirect_to profile_path,
                  alert: "У вас уже есть активная бронь (№#{active_booking.booking_number}) до #{active_booking.ends_at.strftime('%H:%M %d.%m.%Y')}. Вы не можете создать новую, пока текущая не завершится или не будет отменена."
      return
    end

    set_seats
    set_working_hours
    set_cart
    set_tables
    set_time_slots
  end

  def time_slots
    date = params[:date]

    if date.blank?
      return render json: { error: "Дата обязательна" }, status: :bad_request
    end

    begin
      selected_date = Date.parse(date)
    rescue ArgumentError
      return render json: { error: "Неверный формат даты" }, status: :bad_request
    end

    working_hours = working_hours_for(selected_date.wday)
    slots = generate_time_slots_for_date(selected_date, working_hours)

    render json: {
      slots: slots,
      working_hours: working_hours,
      current_time: Time.current.strftime("%H:%M"),
      current_date: Date.current.strftime("%Y-%m-%d")
    }
  end

  def check_availability
    date = params[:date]
    start_time = params[:start_time]
    end_time = params[:end_time]

    if date.blank? || start_time.blank? || end_time.blank?
      return render json: { error: "Необходимо указать дату, время начала и окончания" }, status: :bad_request
    end

    begin
      start_datetime = DateTime.parse("#{date} #{start_time}")
      end_datetime = DateTime.parse("#{date} #{end_time}")
    rescue ArgumentError
      return render json: { error: "Неверный формат даты или времени" }, status: :bad_request
    end

    if end_time == "00:00"
      end_datetime = end_datetime + 1.day
    end

    if end_datetime <= start_datetime
      return render json: { error: "Время окончания должно быть позже времени начала" }, status: :bad_request
    end

    if (end_datetime - start_datetime) > 5.hours
      return render json: { error: "Максимальная длительность бронирования - 5 часов" }, status: :bad_request
    end

    day_of_week = start_datetime.wday
    working_hours = working_hours_for(day_of_week)

    if start_datetime.strftime("%H:%M") < working_hours[:open]
      return render json: { error: "Выбранное время вне часов работы заведения" }, status: :bad_request
    end

    if working_hours[:close] != "00:00" && end_datetime.strftime("%H:%M") > working_hours[:close]
      return render json: { error: "Выбранное время вне часов работы заведения" }, status: :bad_request
    end

    if start_datetime < DateTime.now
      return render json: { error: "Нельзя забронировать столик на прошедшее время" }, status: :bad_request
    end

    min_booking_time = DateTime.now + 15.minutes
    if start_datetime < min_booking_time
      return render json: { error: "Минимальное время для бронирования - через 15 минут" }, status: :bad_request
    end

    overlapping_bookings = Booking.confirmed.where(
      "(starts_at <= ? AND ends_at > ?) OR (starts_at < ? AND ends_at >= ?)",
      end_datetime, start_datetime, end_datetime, start_datetime
    )

    booked_seat_ids = BookingSeat.where(booking_id: overlapping_bookings.pluck(:id)).pluck(:seat_id)
    booked_seats = Seat.where(id: booked_seat_ids)
    booked_table_ids = booked_seats.pluck(:table_id).compact.uniq

    seats_with_status = SEATS_COORDS.map do |coords|
      seat = Seat.find_by(number: coords[:num])
      next unless seat

      status = if booked_seat_ids.include?(seat.id)
                   STATUSES[:occupied]
      else
                   STATUSES[:available]
      end

      {
        id: seat.number,
        status: status
      }
    end.compact

    tables_with_status = TABLE_COORDS.map do |coords|
      table = Table.find_by(id: coords[:num])
      next unless table

      status = if booked_table_ids.include?(table.id)
                   STATUSES[:occupied]
      else
                   STATUSES[:available]
      end

      {
        id: table.id,
        status: status
      }
    end.compact

    render json: {
      seats: seats_with_status,
      tables: tables_with_status
    }
  end

  def create
    active_booking = Booking.where(user: current_user, status: ["confirmed", "pending"])
                           .where("ends_at > ?", Time.current)
                           .first
    if active_booking
      render json: { error: "У вас уже есть активная бронь. Вы не можете создать новую." }, status: :forbidden
      return
    end

    date = params[:reservation][:date]
    start_time = params[:reservation][:start_time]
    end_time = params[:reservation][:end_time]
    seat_ids = params[:reservation][:seat_ids]
    table_ids = params[:reservation][:table_ids]
    require_passport = params[:reservation][:require_passport] == "true"
    special_requests = params[:reservation][:special_requests]

    if date.blank? || start_time.blank? || end_time.blank?
      return render json: { error: "Необходимо указать дату, время начала и окончания" }, status: :bad_request
    end

    # --- ШАГ 1: ПРЕОБРАЗУЕМ И ОЧИЩАЕМ ДАННЫЕ ---
    selected_seat_ids = Array.wrap(seat_ids).map(&:to_i).compact
    selected_table_ids = Array.wrap(table_ids).map(&:to_i).compact

    if selected_seat_ids.blank? && selected_table_ids.blank?
      return render json: { error: "Необходимо выбрать хотя бы одно место или стол" }, status: :bad_request
    end

    # --- ИСПРАВЛЕНО: Определяем тип бронирования, не очищая массивы ID ---
    if selected_table_ids.present?
      # Если выбран хотя бы один стол, считаем бронирование типа "whole_table"
      # Логика расчета цены в модели все равно корректно обработает и отдельные места
      booking_type = "whole_table"
    else
      # Иначе это бронирование отдельных мест
      booking_type = "individual_seats"
    end

    # --- ШАГ 2: ВАЛИДАЦИЯ ВРЕМЕНИ И ДЛИТЕЛЬНОСТИ ---
    begin
      start_datetime = Time.zone.parse("#{date} #{start_time}")
      end_datetime = Time.zone.parse("#{date} #{end_time}")

      if end_time == "00:00"
        end_datetime = end_datetime + 1.day
      end
    rescue ArgumentError
      return render json: { error: "Неверный формат даты или времени" }, status: :bad_request
    end

    if end_datetime <= start_datetime
      return render json: { error: "Время окончания должно быть позже времени начала" }, status: :bad_request
    end

    if (end_datetime - start_datetime) > 5.hours
      return render json: { error: "Максимальная длительность бронирования - 5 часов" }, status: :bad_request
    end

    day_of_week = start_datetime.wday
    working_hours = working_hours_for(day_of_week)

    if start_datetime.strftime("%H:%M") < working_hours[:open] ||
       (end_datetime.strftime("%H:%M") > working_hours[:close] && working_hours[:close] != "00:00")
      return render json: { error: "Выбранное время вне часов работы заведения" }, status: :bad_request
    end

    # --- ШАГ 3: СОЗДАНИЕ БРОНИРОВАНИЯ И ЗАКАЗА ---
    ActiveRecord::Base.transaction do
      # Создаём бронирование
      booking = Booking.create!(
        user_id: current_user.id,
        starts_at: start_datetime,
        ends_at: end_datetime,
        require_passport: require_passport,
        status: "confirmed",
        booking_type: booking_type,
        special_requests: special_requests,
        total_price: 0
      )

      # Собираем все ID мест в один массив
      seat_ids_to_add = []

      # Добавляем места из выбранных столов
      if selected_table_ids.present?
        selected_table_ids.each do |table_id|
          table = Table.find(table_id)
          seat_ids_to_add.concat(table.seats.pluck(:id))
        end
      end

      # Добавляем отдельно выбранные места
      if selected_seat_ids.present?
        seat_ids_to_add.concat(selected_seat_ids)
      end

      # Убираем дубликаты и создаём связи
      seat_ids_to_add.uniq.each do |seat_id|
        BookingSeat.create!(booking_id: booking.id, seat_id: seat_id)
      end

      # Пересчитываем цену
      booking.save!

      # --- Часть 3: Создаем заказ из корзины ---
      cart = Cart.for_user!(current_user)

      if cart.cart_items.active.any?
        # Создаем заказ через ассоциацию, чтобы установить двустороннюю связь
        order = booking.create_order!(
          user_id: current_user.id,
          status: 'pending',
          total_amount: 0
        )

        total_order_amount = 0

        cart.cart_items.active.includes(:dish, cart_item_ingredients: :ingredient).find_each do |cart_item|
          special_instructions = generate_special_instructions(cart_item)
          unit_price = (cart_item.base_price_cents + cart_item.ingredients_extra_cents) / 100.0

          order_item = order.order_items.create!(
            dish: cart_item.dish,
            quantity: cart_item.quantity,
            unit_price: unit_price,
            special_instructions: special_instructions
          )
          total_order_amount += order_item.total_price
        end

        order.update!(total_amount: total_order_amount)
        cart.cart_items.destroy_all
      end

      render json: {
        id: booking.id,
        message: "Бронирование успешно создано",
        booking_number: booking.booking_number
      }, status: :created
    end
  rescue => e
    Rails.logger.error "Booking creation failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { error: e.message }, status: :internal_server_error
  end

  def details
    unless current_user == @booking.user
      redirect_to root_path, alert: "Доступ запрещён!"
    end
  end

  def update
    if @booking.update(booking_params)
      redirect_to reservation_details_path(@booking), notice: "Бронирование успешно обновлено"
    else
      render :details
    end
  end
  
  def cancel
    ActiveRecord::Base.transaction do
      # Отменяем бронирование
      @booking.update!(status: "cancelled")
      
      # Если у бронирования есть заказ, тоже отменяем его
      if @booking.order
        @booking.order.update!(status: "cancelled")
      end
    end

    redirect_to profile_path, notice: "Бронирование и заказ успешно отменены"
  rescue => e
    redirect_to profile_path, alert: "Не удалось отменить бронирование: #{e.message}"
  end

  private

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

  def generate_time_slots_for_date(date, working_hours)
    slots = []
    current_time = Time.parse("#{date} #{working_hours[:open]}")
    end_time = Time.parse("#{date} #{working_hours[:close]}")

    if working_hours[:close] == "00:00"
      end_time = end_time + 1.day
    end

    while current_time < end_time
      (1..5).each do |duration|
        slot_end = current_time + duration.hours

        if slot_end <= end_time
          slots << {
            start_time: current_time.strftime("%H:%M"),
            end_time: slot_end.strftime("%H:%M"),
            duration: duration,
            available: true
          }
        end
      end

      current_time = current_time + 15.minutes
    end

    slots
  end

  def set_reservation
    @reservation = Booking.find(params[:id])
    @booking = @reservation
  end

  def booking_params
    params.require(:booking).permit(:special_requests)
  end

  def set_seats
    seats = Seat.all
    @seats = SEATS_COORDS.map do |coords|
      seat = seats.find_by(number: coords[:num])
      next unless seat
      {
        id:        seat.number,
        x_percent: coords[:x_percent],
        y_percent: coords[:y_percent],
        status:    seat.active ? STATUSES[:available] : STATUSES[:occupied],
        table_id:  seat.table_id
      }
    end.compact
  end

  def set_tables
    tables = Table.order(:id)
    @tables = TABLE_COORDS.zip(tables).map do |coords, table|
      next unless table
      {
        id:             table.id,
        name:           table.name,
        status:         table.active ? STATUSES[:available] : STATUSES[:occupied],
        seats_count:    table.seats_count,
        booking_price:  table.booking_price,
        x_percent:      coords[:x_percent],
        y_percent:      coords[:y_percent],
        width_percent:  coords[:width_percent],
        height_percent: coords[:height_percent]
      }
    end.compact
  end

  def set_working_hours
    @working_hours = {
      1..4 => { open: "09:00", close: "23:00" },
      5..6 => { open: "09:00", close: "00:00" },
      0..0 => { open: "09:00", close: "23:00" }
    }
  end

  def working_hours_for(day)
    case day
    when 1..4 then { open: "09:00", close: "23:00" }
    when 5..6 then { open: "09:00", close: "00:00" }
    else           { open: "09:00", close: "23:00" }
    end
  end

  def set_cart
    @cart = Cart.for_user!(current_user)
    @total_price = @cart.total_cents / 100.0
    @total_items = @cart.total_items_count
  end

  def set_time_slots
    date = params[:date] || Date.today.strftime("%Y-%m-%d")
    @selected_date = Date.parse(date) rescue Date.today
    working_hours = working_hours_for(@selected_date.wday)
    @time_slots = generate_time_slots_for_date(@selected_date, working_hours)
  end

  def status_class(status)
    STATUS_CLASSES[status.to_sym] || "bg-base-300"
  end

  def status_badge_class(status)
    BOOKING_STATUS_CLASSES[status.to_sym] || "badge-neutral"
  end

  helper_method :status_class, :status_badge_class, :working_hours_for
end
