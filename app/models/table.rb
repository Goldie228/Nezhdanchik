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
  # Связь с местами. dependent: :destroy обеспечивает целостность при удалении стола
  has_many :seats, dependent: :destroy
  # Связь с бронированиями через промежуточные таблицы (seats -> booking_seats -> bookings)
  has_many :booking_seats, through: :seats
  has_many :bookings, through: :booking_seats

  # Валидация обязательности названия и количества мест
  validates :name, :seats_count, presence: true
  # Количество мест должно быть положительным числом
  validates :seats_count, numericality: { greater_than: 0 }

  # Фильтр для получения только активных столов
  scope :active, -> { where(active: true) }

  # Рассчитывает количество свободных мест за столом в заданный временной интервал
  def available_seats_count(start_time, end_time)
    return seats_count if start_time.blank? || end_time.blank?

    # Находим места, которые забронированы в выбранное время.
    # Используем SQL JOIN для оптимизации.
    # Условие пересечения: Starts_A < Ends_B AND Ends_A > Starts_B
    booked_seats = seats.joins(:bookings)
                        .where(bookings: { status: [ "confirmed", "active" ] })
                        .where("bookings.starts_at < ? AND bookings.ends_at > ?", end_time, start_time)
                        .count

    # Возвращаем разницу между общим количеством мест и занятыми
    seats_count - booked_seats
  end
end
