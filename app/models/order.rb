# == Schema Information
#
# Table name: orders
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  order_number :string           not null
#  total_amount :decimal(10, 2)   not null
#  status       :string           default("pending")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  booking_id   :bigint
#
class Order < ApplicationRecord
  # Связь с пользователем обязательна (заказ всегда привязан к аккаунту клиента)
  belongs_to :user

  # Связь с бронью опциональна: заказ может быть связан со столом (в зале) или быть без него (доставка)
  belongs_to :booking, optional: true

  # Каскадное удаление позиций при удалении заказа для поддержания целостности данных
  has_many :order_items, dependent: :destroy
  # Прямой доступ к блюдам в заказе через промежуточную модель OrderItem
  has_many :dishes, through: :order_items

  # Уникальность номера критична для корректной работы системы оплаты и чеков
  validates :order_number, uniqueness: true

  # Защита от отрицательной суммы заказа
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

  # Колбэк для автоматического присвоения уникального идентификатора
  before_validation :generate_order_number, on: :create

  # Инициализация суммы нулевым значением, чтобы избежать ошибок при расчетах
  before_validation :set_default_total_amount

  # Генерирует читаемый номер заказа на основе времени и случайного числа
  def generate_order_number
    # Формат: ORD{timestamp}_{random} обеспечивает сортируемость и уникальность
    self.order_number ||= "ORD#{Time.current.to_i}#{rand(100..999)}"
  end

  # Пересчитывает итоговую стоимость заказа, суммируя стоимости всех позиций
  def calculate_total
    # Использует агрегацию SQL (sum) для производительности вместо Ruby-цикла
    update(total_amount: order_items.sum(:total_price))
  end

  private

  def set_default_total_amount
    # Предотвращает ошибки, если total_amount не был передан явно при создании
    self.total_amount = 0 if total_amount.nil?
  end
end
