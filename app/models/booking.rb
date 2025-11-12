# == Schema Information
#
# Table name: bookings
#
#  id               :bigint           not null, primary key
#  user_id          :bigint           not null
#  cart_id          :bigint
#  starts_at        :datetime         not null
#  ends_at          :datetime         not null
#  booking_type     :integer          default("individual_seats"), not null
#  require_passport :boolean          default(FALSE)
#  status           :string           default("pending")
#  booking_number   :string           not null
#  total_price      :decimal(8, 2)    default(0.0)
#  special_requests :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  order_id         :bigint
#
class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :cart, optional: true
  belongs_to :order, optional: true
  has_many :booking_seats, dependent: :destroy
  has_many :seats, through: :booking_seats

  enum :booking_type, { individual_seats: 0, whole_table: 1 }

  validates :starts_at, :ends_at, :booking_number, presence: true
  validates :booking_number, uniqueness: true
  validate :ends_after_starts
  validate :no_overlapping_bookings

  before_validation :generate_booking_number, on: :create
  before_save :calculate_total_price

  scope :future, -> { where("starts_at > ?", Time.current) }
  scope :active, -> { where("starts_at <= ? AND ends_at >= ?", Time.current, Time.current) }
  scope :confirmed, -> { where(status: "confirmed") }

  def duration_hours
    ((ends_at - starts_at) / 1.hour).round
  end

  def table
    seats.first.table if seats.any?
  end

  private

  def generate_booking_number
    self.booking_number ||= "BK#{Time.current.to_i}#{rand(100..999)}"
  end

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?
    errors.add(:ends_at, "должно быть после времени начала") if ends_at <= starts_at
  end

  def no_overlapping_bookings
    return if starts_at.blank? || ends_at.blank? || seats.empty?

    overlapping = Booking.joins(:seats)
                        .where(seats: { id: seat_ids })
                        .where(status: [ "confirmed", "active" ])
                        .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
                        .where.not(id: id)
                        .exists?

    errors.add(:base, "Некоторые места уже забронированы на это время") if overlapping
  end

  def calculate_total_price
    if whole_table? && seats.any?
      # Используем первый seat для получения table, но убеждаемся что он существует
      first_seat = seats.first
      self.total_price = first_seat&.table&.booking_price || 0
    else
      self.total_price = 0 # бесплатно для отдельных мест
    end
  end
end
