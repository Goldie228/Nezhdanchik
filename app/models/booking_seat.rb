# == Schema Information
#
# Table name: booking_seats
#
#  id         :bigint           not null, primary key
#  booking_id :bigint           not null
#  seat_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class BookingSeat < ApplicationRecord
  # Связь с бронированием
  belongs_to :booking
  # Связь с конкретным местом
  belongs_to :seat

  # Гарантирует, что одно и то же место нельзя добавить в одну бронь дважды
  validates :booking_id, uniqueness: { scope: :seat_id }

  # Кастомная валидация для проверки бизнес-логики (занятость места)
  validate :seat_available_for_booking_time

  private

  # Проверяет, свободно ли место на время бронирования
  # Критично для предотвращения двойных бронирований (double booking)
  def seat_available_for_booking_time
    return if booking.blank? || seat.blank?

    # Ищем пересечения по времени с другими подтвержденными/активными бронями
    overlapping_bookings = Booking.joins(:booking_seats)
                                    .where(booking_seats: { seat_id: seat_id })
                                    .where(status: [ "confirmed", "active" ])
                                    .where("starts_at < ? AND ends_at > ?", booking.ends_at, booking.starts_at)
                                    .where.not(id: booking_id)
                                    .exists?

    errors.add(:seat_id, "уже забронировано на это время") if overlapping_bookings
  end
end
