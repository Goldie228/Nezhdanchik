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
end
