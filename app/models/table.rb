# == Schema Information
#
# Table name: tables
#
#  id            :bigint           not null, primary key
#  name          :string           not null
#  seats_count   :integer          not null
#  booking_price :decimal(8, 2)    default(0.0)
#  active        :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Table < ApplicationRecord
  has_many :seats, dependent: :destroy
  has_many :booking_seats, through: :seats
  has_many :bookings, through: :booking_seats

  validates :name, :seats_count, presence: true
  validates :seats_count, numericality: { greater_than: 0 }
  
  scope :active, -> { where(active: true) }

  def available_seats_count(start_time, end_time)
    booked_seats = bookings.where("starts_at < ? AND ends_at > ?", end_time, start_time)
                          .where(status: ['confirmed', 'active'])
                          .joins(:seats)
                          .select('seats.id')
    seats_count - booked_seats.count
  end
end
