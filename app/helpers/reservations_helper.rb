
module ReservationsHelper
  BOOKING_STATUS_CLASSES = {
    pending: "badge-warning",
    confirmed: "badge-success",
    cancelled: "badge-error",
    completed: "badge-info"
  }.freeze

  def status_badge_class(status)
    BOOKING_STATUS_CLASSES[status.to_sym] || "badge-neutral"
  end

  def status_in_russian(status)
    {
      "pending"   => "В ожидании",
      "confirmed" => "Подтверждено",
      "cancelled" => "Отменено",
      "completed" => "Завершено"
    }[status]
  end
end
