
class Avo::Resources::DishIngredient < Avo::BaseResource
  # Используем ID как заголовок, так как это связующая таблица без собственного названия
  self.title = :id
  # Ключ для локализации интерфейса админки
  self.translation_key = "avo.resource_translations.dish_ingredient"

  def fields
    field :id, as: :id

    # Связь с блюдом, к которому относится ингредиент
    field :dish, as: :belongs_to

    # Связь с ингредиентом.
    # searchable: true позволяет искать по имени ингредиента в выпадающем списке.
    # attach_scope: -> { Ingredient.available } фильтрует выборку, показывая только доступные ингредиенты.
    field :ingredient, as: :belongs_to, searchable: true, attach_scope: -> { Ingredient.available }

    # Указывает, входит ли ингредиент в состав блюда по умолчанию
    field :default, as: :boolean
  end
end
