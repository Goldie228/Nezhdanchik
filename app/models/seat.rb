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
  # Место принадлежит конкретному столику
  belongs_to :table

  # Промежуточная таблица для связи многие-ко-многим с бронированиями
  # dependent: :destroy гарантирует удаление связей при удалении места
  has_many :booking_seats, dependent: :destroy

  # Удобный способ получить список всех бронирований для этого места
  has_many :bookings, through: :booking_seats

  # Номер места обязателен
  validates :number, presence: true

  # Критичная валидация: номер места должен быть уникален в рамках одного столика.
  # (Например, за столом 5 может быть только одно место №1).
  validates :number, uniqueness: { scope: :table_id, message: "уже существует для этого столика" }

  # Фильтр для получения только активных мест (исключает, например, места на ремонте)
  scope :active, -> { where(active: true) }

  # Проверяет, свободно ли место в заданный временной интервал
  # Использует SQL-условие пересечения интервалов: Starts(A) < Ends(B) AND Ends(A) > Starts(B)
  # Учитывает только активные или подтвержденные брони.
  def available?(start_time, end_time)
    bookings.where("starts_at < ? AND ends_at > ?", end_time, start_time)
                .where(status: [ "confirmed", "active" ])
                .none?
  end
end
