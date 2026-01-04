# == Schema Information
#
# Table name: cart_items
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cart_id    :bigint           not null
#  quantity   :integer          default(1), not null
#  active     :boolean          default(TRUE), not null
#  dish_id    :bigint           not null
#
require "digest"

class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :dish
  # Позволяет обращаться к ингредиентам напрямую, минуя промежуточную модель
  has_many :ingredients, through: :cart_item_ingredients
  # Связующая таблица для кастомизации состава (добавить/убрать ингредиент)
  has_many :cart_item_ingredients, dependent: :destroy, inverse_of: :cart_item

  validates :cart, presence: true
  # Количество должно быть целым положительным числом
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }, presence: true
  validates :active, inclusion: { in: [ true, false ] }

  # Фильтрует только активные записи (используется для мягкого удаления)
  scope :active, -> { where(active: true) }

  # При создании позиции копируем состав блюда, чтобы пользователь мог его кастомизировать
  after_create :build_ingredients_from_dish, if: -> { dish.present? }

  # Расчет полной стоимости позиции (в копейках) с учетом количества и модификаторов
  def subtotal_cents
    (base_price_cents + ingredients_extra_cents) * quantity
  end

  # Базовая цена блюда, конвертированная в копейки для точности вычислений
  def base_price_cents
    if dish && dish.respond_to?(:price)
      (dish.price.to_d * 100).to_i
    else
      0
    end
  end

  # Расчет надбавки/скидки от ингредиентов.
  # Если ингредиент "по умолчанию" убран — вычитаем цену, если "добавочный" добавлен — прибавляем.
  def ingredients_extra_cents
    cart_item_ingredients.to_a.sum do |cii|
      if cii.default_in_dish
        cii.included ? 0 : -cii.price.to_i
      else
        cii.included ? cii.price.to_i : 0
      end
    end
  end

  # Возвращает ID ингредиентов, которые пользователь добавил дополнительно
  def added_ingredient_ids
    cart_item_ingredients.where(default_in_dish: false, included: true).pluck(:ingredient_id).map(&:to_i).sort
  end

  # Возвращает ID ингредиентов, которые пользователь убрал из блюда
  def removed_ingredient_ids
    cart_item_ingredients.where(default_in_dish: true, included: false).pluck(:ingredient_id).map(&:to_i).sort
  end

  # Сравнивает текущий состав с переданным списком ID (используется при поиске дублей в корзине)
  def matches_composition?(selected_ids, removed_ids)
    Array(selected_ids).map(&:to_i).sort == added_ingredient_ids &&
      Array(removed_ids).map(&:to_i).sort == removed_ingredient_ids
  end

  # Расчет веса одного блюда с учетом изменений в ингредиентах
  def per_item_weight_g
    base_weight_g + ingredients_extra_weight_g
  end

  def base_weight_g
    dish&.weight.to_i
  end

  # Аналогично ценам: добавляем вес добавленных ингредиентов и вычитаем вес убранных
  def ingredients_extra_weight_g
    cart_item_ingredients.to_a.sum do |cii|
      w = cii.ingredient&.weight.to_i
      if cii.default_in_dish
        cii.included ? 0 : -w
      else
        cii.included ? w : 0
      end
    end
  end

  def total_weight_g
    per_item_weight_g * quantity.to_i
  end

  private

  # Инициализирует ингредиенты для новой позиции корзины на основе состава блюда
  def build_ingredients_from_dish
    return unless dish.respond_to?(:dish_ingredients)

    ActiveRecord::Base.transaction do
      dish.dish_ingredients.includes(:ingredient).each do |di|
        cart_item_ingredients.create!(
          ingredient: di.ingredient,
          included: di.default,
          default_in_dish: di.default,
          # Приоритет цены из DishIngredient (если задана кастомная цена для блюда), иначе берем из Ingredient
          price: if di.respond_to?(:price) && di.price.present?
                   (di.price.to_d * 100).to_i
                 else
                   (di.ingredient.price.to_d * 100).to_i
                 end
        )
      end

      save! if changed?
    end
  rescue => e
    Rails.logger.error("CartItem#build_ingredients_from_dish error: #{e.class} #{e.message}")
    raise
  end
end
