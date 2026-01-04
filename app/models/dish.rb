# == Schema Information
#
# Table name: dishes
#
#  id                   :bigint           not null, primary key
#  title                :string           not null
#  description          :text
#  price                :decimal(10, 2)   not null
#  slug                 :string           not null
#  active               :boolean          default(TRUE)
#  cooking_time_minutes :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  category_id          :bigint
#  weight               :integer          default(100), not null
#
class Dish < ApplicationRecord
  # Связь блюда с категорией для группировки в меню
  belongs_to :category

  # Поддержка загрузки нескольких изображений (галерея блюда) через ActiveStorage
  has_many_attached :photos

  # Промежуточная таблица состава. dependent: :destroy обеспечивает целостность при удалении блюда.
  has_many :dish_ingredients, dependent: :destroy
  # Удобная ассоциация для доступа к объектам ингредиентов прямо из блюда
  has_many :ingredients, through: :dish_ingredients

  # Информация о КБЖУ (калорийность), привязана 1 к 1
  has_one :nutrition, dependent: :destroy

  # Связи с позициями в заказах и корзинах (обратные связи)
  has_many :order_items, dependent: :destroy
  has_many :cart_items, dependent: :destroy

  # Валидация названия (обязательно для отображения в меню)
  validates :title, presence: true, length: { maximum: 255 }

  # Цена должна быть положительной. Ограничение < 1М защищает от ошибок ввода.
  validates :price, presence: true,
                    numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000 }

  # Slug (человеко-понятный URL) должен быть уникальным для SEO и маршрутизации
  validates :slug, presence: true, uniqueness: true, length: { maximum: 255 }

  # Время приготовления в минутах (целое число), если указано
  validates :cooking_time_minutes,
            numericality: { only_integer: true, greater_than: 0 },
            allow_nil: true

  # Описание опционально, но ограничено по длине
  validates :description, length: { maximum: 5000 }, allow_blank: true

  # Проверка загружаемых файлов: только картинки (png/jpeg) размером до 5 МБ
  validates :photos,
            content_type: %w[image/png image/jpeg],
            size: { less_than: 5.megabytes }

  # Вес блюда в граммах (используется для расчета общей доставки и КБЖУ)
  validates :weight,
            numericality: { only_integer: true, greater_than: 0, less_than: 10_000 }

  # Скоп для получения только активных блюд (используется на сайте)
  scope :active, -> { where(active: true) }

  # Возвращает ингредиенты, которые входят в состав блюда по умолчанию (базовый рецепт)
  def default_ingredients
    ingredients.merge(DishIngredient.where(default: true))
  end

  # Возвращает ингредиенты, которые можно добавить дополнительно (модификаторы рецепта)
  def optional_ingredients
    ingredients.merge(DishIngredient.where(default: false))
  end
end
