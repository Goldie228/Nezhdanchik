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
  belongs_to :booking
  belongs_to :seat

  validates :booking_id, uniqueness: { scope: :seat_id }
  validate :seat_available_for_booking_time

  private

  def seat_available_for_booking_time
    return if booking.blank? || seat.blank?

    overlapping_bookings = Booking.joins(:booking_seats)
                                    .where(booking_seats: { seat_id: seat_id })
                                    .where(status: [ "confirmed", "active" ])
                                    .where("starts_at < ? AND ends_at > ?", booking.ends_at, booking.starts_at)
                                    .where.not(id: booking_id)
                                    .exists?

    errors.add(:seat_id, "уже забронировано на это время") if overlapping_bookings
  end
end
