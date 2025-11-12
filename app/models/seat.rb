# == Schema Information
#
# Table name: seats
#
#  id         :bigint           not null, primary key
#  table_id   :bigint           not null
#  number     :integer          not null
#  active     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Seat < ApplicationRecord
  belongs_to :table
  has_many :booking_seats, dependent: :destroy
  has_many :bookings, through: :booking_seats

  validates :number, presence: true
  validates :number, uniqueness: { scope: :table_id, message: "уже существует для этого столика" }

  scope :active, -> { where(active: true) }

  def available?(start_time, end_time)
    bookings.where("starts_at < ? AND ends_at > ?", end_time, start_time)
            .where(status: [ "confirmed", "active" ])
            .none?
  end
end
