class Cart < ApplicationRecord
  belongs_to :user

  has_many :cart_items, dependent: :destroy

  validates :user_id, presence: true, uniqueness: true

  # Возвращает сумму корзины в копейках (целое поле price в cart_item_ingredients предполагается в копейках)
  def total_cents
    cart_items.sum(&:subtotal_cents)
  end

  # Количество позиций (с учётом quantity каждой позиции)
  def total_items_count
    cart_items.sum(:quantity)
  end

  # Создать или вернуть существующую корзину для пользователя
  def self.for_user!(user)
    find_or_create_by!(user: user)
  end
end
