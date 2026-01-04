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
  # Связь с пользователем, создавшим бронирование
  belongs_to :user
  # Корзина опциональна (бронь можно создать без предзаказа еды)
  belongs_to :cart, optional: true
  # Заказ может быть привязан позже или отсутствовать, если бронь только на стол
  belongs_to :order, optional: true

  # Также связь через Order (если Order имеет belongs_to :booking)
  # Примечание: наличие обоих типов связи зависит от схемы БД
  has_one :order

  # Промежуточная таблица для связи многие-ко-многим с местами
  has_many :booking_seats, dependent: :destroy
  # Удобный доступ к списку забронированных мест
  has_many :seats, through: :booking_seats

  # Тип бронирования: 0 - отдельные места, 1 - весь стол целиком
  enum :booking_type, { individual_seats: 0, whole_table: 1 }

  # Валидации обязательных полей и уникальности номера брони
  validates :starts_at, :ends_at, :booking_number, presence: true
  validates :booking_number, uniqueness: true

  # Кастомные валидации бизнес-логики
  validate :ends_after_starts
  validate :max_duration
  validate :no_overlapping_bookings

  # Колбэки жизненного цикла записи
  before_validation :generate_booking_number, on: :create
  before_save :calculate_total_price
  # Обновляет статус при каждой загрузке записи из БД (например,过期 бронь)
  after_find :check_and_update_status_if_expired

  # Scopes для удобной фильтрации запросов
  scope :future, -> { where("starts_at > ?", Time.current) }
  # Активные брони — те, что происходят прямо сейчас
  scope :active, -> { where("starts_at <= ? AND ends_at >= ?", Time.current, Time.current) }
  scope :confirmed, -> { where(status: "confirmed") }

  # Рассчитывает длительность бронирования в часах
  def duration_hours
    ((ends_at - starts_at) / 1.hour).round
  end

  # Возвращает объект стола, к которому принадлежит первое место в бронировании
  def table
    seats.first.table if seats.any?
  end

  # Проверяет, происходит ли бронь в текущий момент времени
  def current?
    starts_at <= Time.current && ends_at >= Time.current
  end

  # Проверяет, запланирована ли бронь на будущее
  def future?
    starts_at > Time.current
  end

  # Проверяет, завершено ли бронирование (время прошло)
  def past?
    ends_at < Time.current
  end

  # Рассчитывает длительность в минутах для точного отображения
  def duration_minutes
    ((ends_at - starts_at) / 1.minute).round
  end

  # Состояния брони (строковые статусы)
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

  # Текстовое представление требования паспорта для UI
  def passport_status_text
    if require_passport?
      "Да, требуется"
    else
      "Нет, не требуется"
    end
  end

  private

  # Генерация уникального номера брони на основе времени и случайного числа
  def generate_booking_number
    self.booking_number ||= "BK#{Time.current.to_i}#{rand(100..999)}"
  end

  # Расчет стоимости: либо фиксированная цена стола, либо сумма цен выбранных мест
  def calculate_total_price
    if whole_table?
      # При бронировании целого стола суммируем цены всех столов (если бы можно было забронить несколько)
      booked_tables = seats.includes(:table).map(&:table).uniq
      self.total_price = booked_tables.sum(&:booking_price)
    else
      # При бронировании отдельных мест цена зависит от их количества
      independent_seats_count = seats.reject { |seat| seat.table.present? }.count
      self.total_price = calculate_seats_price(independent_seats_count)
    end
  end

  # Автоматически переводит завершенные брони в статус "completed" при загрузке
  def check_and_update_status_if_expired
    if ends_at < Time.current && (status == "confirmed" || status == "pending")
      self.status = "completed"
    end
  end

  # Валидация: дата окончания должна быть позже даты начала
  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?
    errors.add(:ends_at, "должно быть после времени начала") if ends_at <= starts_at
  end

  # Бизнес-правило: бронирование не может длиться более 5 часов
  def max_duration
    return if starts_at.blank? || ends_at.blank?

    duration = ends_at - starts_at
    if duration > 5.hours
      errors.add(:base, "Максимальная длительность бронирования - 5 часов")
    end
  end

  # Критичная валидация: проверка пересечения времени с другими бронированиями тех же мест
  def no_overlapping_bookings
    return if starts_at.blank? || ends_at.blank? || seats.empty?

    # Ищем пересечения: Starts(A) < Ends(B) AND Ends(A) > Starts(B)
    overlapping = Booking.joins(:seats)
                        .where(seats: { id: seat_ids })
                        .where(status: [ "confirmed", "active" ])
                        .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
                        .where.not(id: id)
                        .exists?

    errors.add(:base, "Некоторые места уже забронированы на это время") if overlapping
  end

  # Класс-метод для массового устаревания старых броней (например, через Cron)
  def self.expire_old_bookings
    where(status: [ "confirmed", "pending" ])
      .where("ends_at < ?", Time.current)
      .update_all(status: "completed", updated_at: Time.current)
  end

  # Принудительное обновление статуса (для менеджеров)
  def ensure_current_status!
    if ends_at < Time.current && (status == "confirmed" || status == "pending")
      update_column(:status, "completed")
      reload
    end
  end

  # Расчет стоимости бронирования мест по шкале (чем больше мест, тем дешевле место)
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
