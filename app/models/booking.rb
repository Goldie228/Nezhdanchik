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

  has_one :order
  has_many :booking_seats, dependent: :destroy
  has_many :seats, through: :booking_seats

  enum :booking_type, { individual_seats: 0, whole_table: 1 }

  validates :starts_at, :ends_at, :booking_number, presence: true
  validates :booking_number, uniqueness: true

  validate :ends_after_starts
  validate :max_duration
  validate :no_overlapping_bookings

  before_validation :generate_booking_number, on: :create
  before_save :calculate_total_price

  after_find :check_and_update_status_if_expired

  scope :future, -> { where("starts_at > ?", Time.current) }
  scope :active, -> { where("starts_at <= ? AND ends_at >= ?", Time.current, Time.current) }
  scope :confirmed, -> { where(status: "confirmed") }

  def duration_hours
    ((ends_at - starts_at) / 1.hour).round
  end

  def table
    seats.first.table if seats.any?
  end

  def current?
    starts_at <= Time.current && ends_at >= Time.current
  end

  def future?
    starts_at > Time.current
  end

  def past?
    ends_at < Time.current
  end

  def duration_minutes
    ((ends_at - starts_at) / 1.minute).round
  end

  def pending?
    status == "pending"
  end

  def confirmed?
    status == "confirmed"
  end

  def cancelled?
    status == "cancelled"
  end

  def completed?
    status == "completed"
  end

  def passport_status_text
    if require_passport?
      "Да, требуется"
    else
      "Нет, не требуется"
    end
  end

  private

  def generate_booking_number
    self.booking_number ||= "BK#{Time.current.to_i}#{rand(100..999)}"
  end

  def calculate_total_price
    if whole_table?
      booked_tables = seats.includes(:table).map(&:table).uniq
      self.total_price = booked_tables.sum(&:booking_price)
    else
      independent_seats_count = seats.reject { |seat| seat.table.present? }.count
      self.total_price = calculate_seats_price(independent_seats_count)
    end
  end

  def check_and_update_status_if_expired
    if ends_at < Time.current && (status == "confirmed" || status == "pending")
      self.status = "completed"
    end
  end

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?
    errors.add(:ends_at, "должно быть после времени начала") if ends_at <= starts_at
  end

  def max_duration
    return if starts_at.blank? || ends_at.blank?

    duration = ends_at - starts_at
    if duration > 5.hours
      errors.add(:base, "Максимальная длительность бронирования - 5 часов")
    end
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

  def self.expire_old_bookings
    where(status: [ "confirmed", "pending" ])
      .where("ends_at < ?", Time.current)
      .update_all(status: "completed", updated_at: Time.current)
  end

  def ensure_current_status!
    if ends_at < Time.current && (status == "confirmed" || status == "pending")
      update_column(:status, "completed")
      reload
    end
  end

  def calculate_seats_price(seat_count)
    case seat_count
    when 0 then 0
    when 1 then 0
    when 2 then 500
    when 3 then 1000
    when 4 then 1500
    when 5 then 1750
    when 6 then 2000
    else 2000 + (seat_count - 6) * 300
    end
  end
end
