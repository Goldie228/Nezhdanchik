
class Avo::Resources::CartItemIngredient < Avo::BaseResource
  # Используем ID как заголовок, так как запись не имеет удобного читаемого идентификатора
  self.title = :id
  self.includes = []
  # Указываем файл переводов для поддержки мультиязычности
  self.translation_key = "avo.resource_translations.cart_item_ingredient"

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"

    # Обязательные связи: позиция в корзине и сам ингредиент
    field :cart_item, as: :belongs_to, translation_key: "avo.field_translations.cart_item", required: true
    field :ingredient, as: :belongs_to, translation_key: "avo.field_translations.ingredient", required: true

    # Статусы ингредиента в конкретной позиции корзины
    field :included, as: :boolean, translation_key: "avo.field_translations.included"
    field :default_in_dish, as: :boolean, translation_key: "avo.field_translations.default"

    # Цена ингредиента на момент добавления (фиксируется в копейках)
    field :price, as: :number, translation_key: "avo.field_translations.price"

    # Служебные поля времени создания и обновления (скрыты в формах)
    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
