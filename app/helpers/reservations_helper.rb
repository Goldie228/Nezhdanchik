
module ReservationsHelper
  # Хэш для маппинга статусов брони на CSS-классы DaisyUI.
  # freeze предотвращает случайное изменение константы в рантайме.
  BOOKING_STATUS_CLASSES = {
    pending: "badge-warning",
    confirmed: "badge-success",
    cancelled: "badge-error",
    completed: "badge-info"
  }.freeze

  # Возвращает соответствующий CSS класс в зависимости от статуса бронирования.
  # Используется для цветовой индикации (красный - отменено, зеленый - подтверждено).
  def status_badge_class(status)
    BOOKING_STATUS_CLASSES[status.to_sym] || "badge-neutral"
  end

  # Переводит технические статусы (ключи) на человекочитаемый русский язык.
  def status_in_russian(status)
    {
      "pending"   => "В ожидании",
      "confirmed" => "Подтверждено",
      "cancelled" => "Отменено",
      "completed" => "Завершено"
    }[status]
  end
end
