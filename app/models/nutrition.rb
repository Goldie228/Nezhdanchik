# == Schema Information
#
# Table name: nutritions
#
#  id            :bigint           not null, primary key
#  proteins      :decimal(5, 2)
#  fats          :decimal(5, 2)
#  carbohydrates :decimal(5, 2)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  dish_id       :bigint
#  ingredient_id :bigint
#
class Nutrition < ApplicationRecord
  # Полиморфная связь позволяет хранить информацию о КБЖУ как для готовых блюд, так и для отдельных ингредиентов
  belongs_to :dish, optional: true
  belongs_to :ingredient, optional: true

  # Обеспечивает целостность полиморфной связи: запись должна относиться ровно к одному родителю (блюду ИЛИ ингредиенту)
  validate :only_one_parent

  # Проверка корректности значений белков, жиров и углеводов.
  # Устанавливает диапазон от 0 до 1000 и позволяет значения быть nil (если данные неизвестны).
  validates :proteins, :fats, :carbohydrates,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 1000
            },
            allow_nil: true

  private

  def only_one_parent
    # Ошибка, если не указан ни один родитель (запись должна быть привязана к чему-то)
    if dish_id.blank? && ingredient_id.blank?
      errors.add(:base, :must_have_parent)
    # Ошибка, если указаны оба родителя (полиморфная связь подразумевает принадлежность к одному типу сущности)
    elsif dish_id.present? && ingredient_id.present?
      errors.add(:base, :cannot_have_both)
    end
  end
end
