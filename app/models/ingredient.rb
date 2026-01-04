# == Schema Information
#
# Table name: ingredients
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  price      :decimal(8, 2)    default(0.0)
#  available  :boolean          default(TRUE)
#  allergen   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  weight     :integer          default(10), not null
#
class Ingredient < ApplicationRecord
  # Промежуточная таблица для связи многие-ко-многим с блюдами (рецепты)
  has_many :dish_ingredients, dependent: :destroy
  # Позволяет найти все блюда, в состав которых входит этот ингредиент
  has_many :dishes, through: :dish_ingredients
  # Информация о калориях/БЖУ привязана к ингредиенту
  has_one :nutrition, dependent: :destroy

  # Изображение ингредиента для отображения в интерфейсе
  has_one_attached :photo

  # Имя должно быть уникальным для четкой идентификации на складе и в меню
  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  # Цена влияет на итоговую стоимость блюда. Ограничения защищают от некорректного ввода.
  validates :price,
            numericality: { greater_than_or_equal_to: 0, less_than: 100_000 }
  # Вес в граммах необходим для расчета калорийности и общего веса блюда
  validates :weight,
            numericality: { only_integer: true, greater_than: 0, less_than: 10_000 }
  # Проверка загружаемого файла: только картинки, размер до 5 МБ
  validates :photo,
            content_type: %w[image/png image/jpeg],
            size: { less_than: 5.megabytes }

  # Возвращает только доступные ингредиенты (актуальные на складе)
  scope :available, -> { where(available: true) }
  # Возвращает ингредиенты, помеченные как аллергены (для предупреждений в меню)
  scope :allergens, -> { where(allergen: true) }
end
