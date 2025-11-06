class ReservationsController < ApplicationController
  # В реальном приложении здесь будет аутентификация, например, через before_action :authenticate_user!

  def new
    # --- Моковые данные для столиков ---
    # Клиент будет задавать x_percent и y_percent для каждого столика.
    # Это процентные координаты относительно левого верхнего угла изображения.
    # 0% - самый верх/лево, 100% - самый низ/право.
    @tables = [
      { id: 1,  x_percent: 37, y_percent: 29, status: "available" },
      { id: 2,  x_percent: 46.4, y_percent: 29, status: "reserved" },
      { id: 3,  x_percent: 37, y_percent: 47.5, status: "occupied" },
      { id: 4,  x_percent: 46.4, y_percent: 47.5, status: "available" },
      { id: 5,  x_percent: 47, y_percent: 8, status: "available" },
      { id: 6,  x_percent: 51, y_percent: 17.8, status: "reserved" },
      { id: 7,  x_percent: 59.8, y_percent: 17.8, status: "available" },
      { id: 8,  x_percent: 68.8, y_percent: 17.8, status: "occupied" },
      { id: 9,  x_percent: 78, y_percent: 17.8, status: "available" },
      { id: 10, x_percent: 81.1, y_percent: 7.9, status: "available" },
      { id: 11, x_percent: 81, y_percent: 29.5, status: "available" },
      { id: 12, x_percent: 90.5, y_percent: 29.5, status: "reserved" },
      { id: 13, x_percent: 81, y_percent: 48, status: "available" },
      { id: 14, x_percent: 90.5, y_percent: 48, status: "occupied" },
      { id: 15, x_percent: 81, y_percent: 69.0, status: "available" },
      { id: 16, x_percent: 75.0, y_percent: 59.0, status: "available" },
      { id: 17, x_percent: 65.9, y_percent: 59.0, status: "available" },
      { id: 18, x_percent: 57.8, y_percent: 59.0, status: "available" },
      { id: 19, x_percent: 50.0, y_percent: 59.0, status: "reserved" },
      { id: 20, x_percent: 46.3, y_percent: 69.0, status: "available" }
    ]

    @working_hours = {
      1..4 => { open: "09:00", close: "23:00" }, # Пн-Чт
      5..6 => { open: "09:00", close: "00:00" }, # Пт-Сб
      0..0 => { open: "09:00", close: "23:00" }  # Вс
    }
  end

  # В реальном приложении здесь будет действие create для обработки формы
  # def create
  #   # Логика сохранения брони в базу данных
  #   # ...
  #   redirect_to root_path, notice: 'Ваша бронь успешно оформлена!'
  # end

  private

  def status_class(status)
    case status.to_sym
    when :available
      "bg-success"
    when :reserved
      "bg-warning"
    when :occupied
      "bg-error"
    else
      "bg-base-300"
    end
  end

  helper_method :status_class
end
