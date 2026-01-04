
class Avo::Resources::Dish < Avo::BaseResource
  # Используем название блюда в качестве заголовка записи
  self.title = :title
  # Жаркая загрузка категории позволяет избежать N+1 запросов при отображении списка блюд
  self.includes = [ :category ]
  # Ключ для локализации интерфейса
  self.translation_key = "avo.resource_translations.dish"

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"
    field :title, as: :text, required: true, translation_key: "avo.field_translations.title"
    field :description, as: :textarea, translation_key: "avo.field_translations.description"

    # Цена обязательна для формирования заказа
    field :price, as: :number, required: true, translation_key: "avo.field_translations.price"

    # Slug используется для формирования человекопонятных URL
    field :slug, as: :text, required: true, translation_key: "avo.field_translations.slug"

    # Блюдо активно по умолчанию при создании
    field :active, as: :boolean, default: true, translation_key: "avo.field_translations.active"

    # Время приготовления в минутах
    field :cooking_time_minutes, as: :number, translation_key: "avo.field_translations.cooking_time_minutes"

    # Вес в граммах (используется для расчета доставки и КБЖУ)
    field :weight, as: :number, translation_key: "avo.field_translations.weight"

    # Связь с категорией (обязательная валидацией на уровне модели)
    field :category, as: :belongs_to, translation_key: "avo.field_translations.category"

    # Галерея изображений (ActiveStorage). direct_upload ускоряет загрузку на S3/Storage.
    field :photos, as: :files, is_image: true, direct_upload: true, multiple: true,
      translation_key: "avo.field_translations.photos"

    # Состав блюда. show_on: :edit скрывает сложный список на главной странице ресурса.
    # attach_scope позволяет видеть доступные ингредиенты при привязке.
    field :dish_ingredients, as: :has_many, show_on: :edit, attach_scope: -> { DishIngredient.all }

    # Информация о КБЖУ (привязана 1 к 1)
    field :nutrition, as: :has_one
  end
end
