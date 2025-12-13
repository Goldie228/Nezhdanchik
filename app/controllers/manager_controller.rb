class ManagerController < ApplicationController
  include ActionView::Helpers::NumberHelper

  before_action :authenticate_user!
  before_action :require_manager_role
  before_action :set_date_range, only: [ :calendar, :tables_view ]
  before_action :set_booking, only: [ :show, :edit, :update, :destroy, :add_dish_to_order, :update_order_item, :remove_order_item ]

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
    { id: 8, x_percent: 68.8, y_percent: 17.8 },
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

  STATUSES = [
    { value: "pending", color: "badge-warning" },
    { value: "confirmed", color: "badge-info" },
    { value: "completed", color: "badge-success" },
    { value: "cancelled", color: "badge-neutral" }
  ].freeze

  WORKING_HOURS = {
    1..4 => { open: "09:00", close: "23:00" },
    5..6 => { open: "09:00", close: "00:00" },
    0..0 => { open: "09:00", close: "23:00" }
  }.freeze

  def dashboard
    @active_bookings = get_active_bookings
    @today_bookings = Booking.includes(:user, :seats, :order)
                             .where(status: [ "pending", "confirmed" ])
                             .where("starts_at >= ? AND starts_at <= ?", Date.current.beginning_of_day, Date.current.end_of_day)
                             .order(starts_at: :asc)

    @tables = Table.includes(:seats).active
    @individual_seats = Seat.where(table_id: nil)
    @current_bookings = Booking.includes(:user, :seats, :order)
                               .where(status: [ "pending", "confirmed" ])
                               .where("starts_at <= ? AND ends_at >= ?", Time.current, Time.current)
    @upcoming_bookings = Booking.includes(:user, :seats, :order)
                               .where(status: [ "pending", "confirmed" ])
                               .where("starts_at > ? AND starts_at <= ?", Time.current, Time.current + 7.days)
                               .order(starts_at: :asc)
                               .limit(10)

    @table_seat_counts = Table.active.includes(:seats).group(:id).count("seats.id")
  end

  def calendar
    @bookings = Booking.includes(:user, :seats, :order)
                      .where(status: [ "pending", "confirmed" ])
                      .where("starts_at >= ? AND starts_at <= ?", @start_date, @end_date)
                      .order(starts_at: :asc)

    @tables = Table.includes(:seats).active
    @individual_seats = Seat.where(table_id: nil)

    @table_seat_counts = Table.active.includes(:seats).group(:id).count("seats.id")
  end

  def tables_view
    @tables = Table.includes(:seats).active
    @current_bookings = Booking.includes(:user, :seats, :order)
                               .where(status: [ "pending", "confirmed" ])
                               .where("starts_at <= ? AND ends_at >= ?", Time.current, Time.current)

    @today_bookings = Booking.includes(:user, :seats, :order)
                             .where(status: [ "pending", "confirmed" ])
                             .where("starts_at >= ? AND starts_at <= ?", Date.current.beginning_of_day, Date.current.end_of_day)
                             .order(starts_at: :asc)

    @seats = Seat.includes(:table).all
  end

  def show
    @order_items = @booking.order&.order_items&.includes(:dish) || []
    @special_requests = @booking.special_requests
  end

  def edit
    @categories = Category.where(active: true).order(:name)
    @order = @booking.order || @booking.build_order(user: @booking.user)
    @order_items = @order.order_items.includes(:dish) || []
  end

  def update
    Rails.logger.info "Updating booking #{@booking.id} with params: #{booking_params.inspect}"

    if @booking.update_column(:status, booking_params[:status])
      @booking.touch(:updated_at)
      redirect_to manager_booking_path(@booking), notice: "Бронирование успешно обновлено"
    else
      Rails.logger.error "Failed to update booking: #{@booking.errors.full_messages.join(', ')}"

      @categories = Category.where(active: true).order(:name)
      @order = @booking.order || @booking.build_order(user: @booking.user)
      @order_items = @order.order_items.includes(:dish) || []

      render :edit, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Exception in update: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    flash[:alert] = "Произошла непредвиденная ошибка: #{e.message}"

    @categories = Category.where(active: true).order(:name)
    @order = @booking.order || @booking.build_order(user: @booking.user)
    @order_items = @order.order_items.includes(:dish) || []

    render :edit, status: :unprocessable_entity
  end

  def destroy
    @booking.update(status: "cancelled")
    redirect_to manager_bookings_path, notice: "Бронирование отменено"
  end

  def dishes_by_category
    category_id = params[:category_id]

    if category_id.blank?
      render json: { success: false, message: "ID категории обязателен" }, status: :bad_request
      return
    end

    category = Category.find(category_id)
    dishes = category.dishes.includes(:ingredients).active

    render json: {
      success: true,
      dishes: dishes.map do |dish|
        {
          id: dish.id,
          title: dish.title,
          description: dish.description,
          price: dish.price,
          ingredients: dish.dish_ingredients.includes(:ingredient).map do |di|
            {
              id: di.ingredient.id,
              name: di.ingredient.name,
              price: di.ingredient.price,
              default: di.default
            }
          end
        }
      end
    }
  rescue => e
    render json: { success: false, message: "Ошибка при загрузке блюд: #{e.message}" }, status: :internal_server_error
  end

  def order_item
    order_item_id = params[:id]

    if order_item_id.blank?
      render json: { success: false, message: "ID элемента заказа обязателен" }, status: :bad_request
      return
    end

    order_item = OrderItem.includes(:dish).find(order_item_id)

    selected_ingredients = []
    removed_ingredients = []

    if order_item.special_instructions.present?
      instructions = order_item.special_instructions.split(";")

      instructions.each do |instruction|
        if instruction.include?("Добавки:")
          added_names = instruction.sub("Добавки:", "").strip.split(",").map(&:strip)
          selected_ingredients = Ingredient.where(name: added_names).pluck(:id)
        elsif instruction.include?("Без:")
          removed_names = instruction.sub("Без:", "").strip.split(",").map(&:strip)
          removed_ingredients = Ingredient.where(name: removed_names).pluck(:id)
        end
      end
    end

    render json: {
      success: true,
      order_item: {
        id: order_item.id,
        quantity: order_item.quantity,
        unit_price: order_item.unit_price,
        special_instructions: order_item.special_instructions,
        selected_ingredients: selected_ingredients,
        removed_ingredients: removed_ingredients,
        dish: {
          id: order_item.dish.id,
          title: order_item.dish.title,
          description: order_item.dish.description,
          price: order_item.dish.price,
          ingredients: order_item.dish.dish_ingredients.includes(:ingredient).map do |di|
            {
              id: di.ingredient.id,
              name: di.ingredient.name,
              price: di.ingredient.price,
              default: di.default
            }
          end
        }
      }
    }
  rescue => e
    render json: { success: false, message: "Ошибка при загрузке элемента заказа: #{e.message}" }, status: :internal_server_error
  end

  def add_dish_to_order
    dish = Dish.find(params[:dish_id])
    selected, removed = normalize_ingredient_params(params)
    quantity = params[:quantity].to_i > 0 ? params[:quantity].to_i : 1

    ActiveRecord::Base.transaction do
      order = @booking.order || @booking.build_order(user: @booking.user)
      order.save! if order.new_record?

      special_instructions = generate_special_instructions_from_params(selected, removed)
      unit_price = calculate_unit_price(dish, selected)
      existing_item = find_existing_order_item(order, dish, special_instructions)

      if existing_item
        existing_item.increment!(:quantity, quantity)
        order_item = existing_item
      else
        order_item = order.order_items.create!(
          dish: dish,
          quantity: quantity,
          unit_price: unit_price,
          special_instructions: special_instructions
        )
      end

      update_order_total(order)
    end

    respond_to do |format|
      format.json do
        render json: {
          success: true,
          message: "Блюдо добавлено в заказ",
          order_total: ActionController::Base.helpers.number_to_currency(@booking.order.total_amount, unit: "BYN", format: "%n %u")
        }
      end
      format.html { redirect_to edit_manager_booking_path(@booking), notice: "Блюдо добавлено в заказ" }
    end
  rescue => e
    Rails.logger.error "Error in add_dish_to_order: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    respond_to do |format|
      format.json do
        render json: {
          success: false,
          message: "Ошибка при добавлении блюда: #{e.message}"
        }, status: :unprocessable_entity
      end
      format.html { redirect_to edit_manager_booking_path(@booking), alert: "Ошибка при добавлении блюда: #{e.message}" }
    end
  end

  def update_order_item
    unless @booking.order
      render json: { success: false, message: "У этого бронирования нет заказа" }, status: :unprocessable_entity
      return
    end

    order_item = @booking.order.order_items.find(params[:order_item_id])
    selected, removed = normalize_ingredient_params(params)
    quantity = params[:quantity].to_i > 0 ? params[:quantity].to_i : 1

    ActiveRecord::Base.transaction do
      special_instructions = generate_special_instructions_from_params(selected, removed)
      unit_price = calculate_unit_price(order_item.dish, selected)

      order_item.update!(
        quantity: quantity,
        unit_price: unit_price,
        special_instructions: special_instructions
      )

      update_order_total(@booking.order)
    end

    respond_to do |format|
      format.json do
        render json: {
          success: true,
          message: "Блюдо обновлено",
          order_total: ActionController::Base.helpers.number_to_currency(@booking.order.total_amount, unit: "BYN", format: "%n %u")
        }
      end
      format.html { redirect_to edit_manager_booking_path(@booking), notice: "Блюдо обновлено" }
    end
  rescue => e
    Rails.logger.error "Error in update_order_item: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    respond_to do |format|
      format.json do
        render json: {
          success: false,
          message: "Ошибка при обновлении блюда: #{e.message}"
        }, status: :unprocessable_entity
      end
      format.html { redirect_to edit_manager_booking_path(@booking), alert: "Ошибка при обновлении блюда: #{e.message}" }
    end
  end

  def remove_order_item
    unless @booking.order
      render json: { success: false, message: "У этого бронирования нет заказа" }, status: :unprocessable_entity
      return
    end

    order_item = @booking.order.order_items.find(params[:order_item_id])

    ActiveRecord::Base.transaction do
      order_item.destroy
      update_order_total(@booking.order)
    end

    respond_to do |format|
      format.json do
        render json: {
          success: true,
          message: "Блюдо удалено из заказа",
          order_total: ActionController::Base.helpers.number_to_currency(@booking.order.total_amount, unit: "BYN", format: "%n %u")
        }
      end
      format.html { redirect_to edit_manager_booking_path(@booking), notice: "Блюдо удалено из заказа" }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.json do
        render json: { success: false, message: "Элемент заказа не найден" }, status: :not_found
      end
    end
  rescue => e
    Rails.logger.error "Error in remove_order_item: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    respond_to do |format|
      format.json do
        render json: {
          success: false,
          message: "Ошибка при удалении блюда: #{e.message}"
        }, status: :unprocessable_entity
      end
      format.html { redirect_to edit_manager_booking_path(@booking), alert: "Ошибка при удалении блюда: #{e.message}" }
    end
  end

  def bookings
    @bookings = Booking.includes(:user, { seats: :table }, :order)

    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @bookings = @bookings.joins(:user).where(
        "bookings.booking_number ILIKE ? OR users.first_name ILIKE ? OR users.last_name ILIKE ? OR users.email ILIKE ? OR users.phone ILIKE ?",
        search_term, search_term, search_term, search_term, search_term
      )
    end

    if params[:status].present?
      if [ "pending", "confirmed" ].include?(params[:status])
        @bookings = @bookings.where(status: params[:status]).where("ends_at > ?", Time.current)
      else
        @bookings = @bookings.where(status: params[:status])
      end
    end

    allowed_columns = %w[booking_number starts_at total_price status created_at users.first_name users.last_name]
    sort_column = (params[:sort] && allowed_columns.include?(params[:sort])) ? params[:sort] : "starts_at"
    sort_direction = (params[:direction] == "asc") ? "asc" : "desc"

    @bookings = @bookings.order("#{sort_column} #{sort_direction}")

    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 20
    per_page = [ [ per_page, 10 ].max, 100 ].min

    @bookings = @bookings.page(params[:page]).per(per_page)
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
    @active_bookings = get_active_bookings

    render partial: "bookings_list", locals: { active_bookings: @active_bookings }, layout: false
  rescue => e
    Rails.logger.error "Error in refresh_bookings: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { success: false, message: "Ошибка при обновлении данных: #{e.message}" }, status: :internal_server_error
  end

  private

  def status_in_russian(status)
    {
      "pending"   => "В ожидании",
      "confirmed" => "Подтверждено",
      "cancelled" => "Отменено",
      "completed" => "Завершено"
    }[status] || status.capitalize
  end

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
    return {} unless params.has_key?(:booking)
    params.require(:booking).permit(:special_requests, :status)
  end

  def get_active_bookings
    Booking.includes(:order, :booking_seats, :seats, :user)
        .where(status: [ "pending", "confirmed" ])
        .where("ends_at > ?", Time.current)
        .order(created_at: :desc)
  end

  def get_status_info(status)
    get_statuses_list.find { |s| s[:value] == status } || { text: status, color: "badge-neutral" }
  end

  def get_statuses_list
    STATUSES.map do |s|
      {
        value: s[:value],
        text: status_in_russian(s[:value]),
        color: s[:color]
      }
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

  def generate_special_instructions_from_params(selected_ids, removed_ids)
    added_names = Ingredient.where(id: selected_ids).pluck(:name)
    removed_names = Ingredient.where(id: removed_ids).pluck(:name)

    instructions = []
    if added_names.any?
      instructions << "Добавки: #{added_names.join(', ')}"
    end

    if removed_names.any?
      instructions << "Без: #{removed_names.join(', ')}"
    end

    instructions.any? ? instructions.join("; ") : nil
  end

  def calculate_unit_price(dish, selected_ids)
    base_price = dish.price
    additional_price = Ingredient.where(id: selected_ids).sum(:price)

    base_price + additional_price
  end

  def find_existing_order_item(order, dish, special_instructions)
    order.order_items.where(dish: dish, special_instructions: special_instructions).first
  end

  def format_phone_number(phone)
    return "Номер не указан" if phone.blank?

    cleaned = phone.gsub(/\D/, "")

    if cleaned.length == 9
      country_code = "+375"
      operator_code = cleaned[0..1]
      first_part = cleaned[2..4]
      second_part = cleaned[5..6]
      third_part = cleaned[7..8]

      return "#{country_code} (#{operator_code}) #{first_part}-#{second_part}-#{third_part}"
    end

    if cleaned.length == 12 && cleaned.start_with?("375")
      country_code = "+375"
      operator_code = cleaned[3..4]
      first_part = cleaned[5..7]
      second_part = cleaned[8..9]
      third_part = cleaned[10..11]

      return "#{country_code} (#{operator_code}) #{first_part}-#{second_part}-#{third_part}"
    end

    phone
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

  def update_order_total(order)
    total_amount = order.order_items.sum(:total_price)
    order.update!(total_amount: total_amount)
  end

  def booking_status_in_russian(status)
    case status
    when "pending"
      "Ожидает"
    when "confirmed"
      "Подтверждено"
    when "completed"
      "Завершено"
    when "cancelled"
      "Отменено"
    else
      status.capitalize
    end
  end

  def get_status_info(status)
    status_data = STATUSES.find { |s| s[:value] == status }
    return { text: status_in_russian(status), color: "badge-neutral" } unless status_data

    {
      text: status_in_russian(status),
      color: status_data[:color]
    }
  end

  def russian_date(date)
    months = {
      1 => "января", 2 => "февраля", 3 => "марта", 4 => "апреля",
      5 => "мая", 6 => "июня", 7 => "июля", 8 => "августа",
      9 => "сентября", 10 => "октября", 11 => "ноября", 12 => "декабря"
    }
    "#{date.day} #{months[date.month]}"
  end

  def sort_link(column, title = nil)
    title ||= column.titleize
    direction = column == params[:sort] && params[:direction] == "asc" ? "desc" : "asc"
    icon = direction == "asc" ? "↑" : "↓"

    link_to manager_bookings_path(sort: column, direction: direction, search: params[:search], status: params[:status], per_page: params[:per_page]),
            class: "flex items-center gap-1" do
      concat title
      if column == params[:sort]
        concat content_tag(:span, icon, class: "text-xs")
      end
    end
  end

  helper_method :booking_status_in_russian
  helper_method :russian_date
  helper_method :generate_special_instructions
  helper_method :status_in_russian
  helper_method :get_statuses_list
  helper_method :get_status_info
  helper_method :format_phone_number

  def require_manager_role
    if current_user&.role&.to_s.in?([ "2", "3" ])
      redirect_to root_path, alert: "Доступ запрещен"
    end
  end
end
