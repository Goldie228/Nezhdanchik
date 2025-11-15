class ReservationsController < ApplicationController
  before_action :authenticate_user!

  STATUSES = { 
    available: "available", 
    reserved: "reserved", 
    occupied: "occupied"
  }.freeze

  STATUS_CLASSES = {
    available: "bg-success",
    reserved:  "bg-warning",
    occupied:  "bg-error"
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
    set_seats
    set_working_hours
    set_cart
    set_tables
  end

  private

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

  def set_working_hours
    @working_hours = {
      1..4 => { open: "09:00", close: "23:00" }, # Пн-Чт
      5..6 => { open: "09:00", close: "00:00" }, # Пт-Сб
      0..0 => { open: "09:00", close: "23:00" }  # Вс
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

  def status_class(status)
    STATUS_CLASSES[status.to_sym] || "bg-base-300"
  end

  helper_method :status_class, :working_hours_for
end
