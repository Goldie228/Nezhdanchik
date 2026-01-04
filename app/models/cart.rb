# == Schema Information
#
# Table name: carts
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  booking_id :bigint
#
class Cart < ApplicationRecord
  # Связь с владельцем корзины
  belongs_to :user
  # Связь с бронированием опциональна (предзаказ еды к столику)
  belongs_to :booking, optional: true
  # Удаляет товары при удалении корзины
  has_many :cart_items, dependent: :destroy
  # Прямой доступ к блюдам в корзине
  has_many :dishes, through: :cart_items

  # У пользователя может быть только одна активная корзина
  validates :user_id, presence: true, uniqueness: true

  # Считает сумму стоимости всех товаров в корзине в копейках
  def total_cents
    cart_items.sum(&:subtotal_cents)
  end

  # Считает общее количество товаров (учитывая quantity)
  def total_items_count
    cart_items.sum(:quantity)
  end

  # Находит или создает корзину для пользователя (паттерн "Ensure existence")
  def self.for_user!(user)
    find_or_create_by!(user: user)
  end
end
