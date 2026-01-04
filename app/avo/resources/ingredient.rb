
class Avo::Resources::Ingredient < Avo::BaseResource
  # Используем название ингредиента как заголовок записи в админке
  self.title = :name
  # Указываем файл переводов для мультиязычности интерфейса
  self.translation_key = "avo.resource_translations.ingredient"

  def fields
    field :id, as: :id

    # Название ингредиента (обязательное поле)
    field :name, as: :text, required: true

    # Цена ингредиента (влияет на стоимость блюда при модификации)
    field :price, as: :number

    # Вес ингредиента в граммах (для расчета КБЖУ и веса блюда)
    field :weight, as: :number, translation_key: "avo.field_translations.weight"

    # Флаг доступности (недоступные ингредиенты нельзя выбрать в блюде)
    field :available, as: :boolean

    # Пометка об аллергенности (важно для информации в меню)
    field :allergen, as: :boolean

    # Изображение ингредиента для меню
    field :photo, as: :file, is_image: true, direct_upload: true

    # Связь с блюдами. attach_scope: -> { Dish.active } позволяет прикреплять ингредиент только к активным блюдам.
    field :dishes, as: :has_many, attach_scope: -> { Dish.active }

    # Информация о КБЖУ (привязана 1 к 1)
    field :nutrition, as: :has_one
  end
end
