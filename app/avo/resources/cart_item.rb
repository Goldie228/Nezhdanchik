
class Avo::Resources::CartItem < Avo::BaseResource
  # Используем ID как заголовок записи, так как у позиции корзины нет уникального имени
  self.title = :id
  self.includes = []
  # Подключение переводов для интерфейса админки
  self.translation_key = "avo.resource_translations.cart_item"

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"

    # Связь с корзиной обязательна для принадлежности позиции
    field :cart, as: :belongs_to, translation_key: "avo.field_translations.cart", required: true
    # Связь с блюдом нужна для отображения названия и цены
    field :dish, as: :belongs_to, translation_key: "avo.field_translations.dish"
    # Количество товара в заказе
    field :quantity, as: :number, translation_key: "avo.field_translations.quantity"
    # Флаг активности позволяет скрывать товары без удаления из БД (Soft Delete)
    field :active, as: :boolean, translation_key: "avo.field_translations.active"

    # Вложенная связь для просмотра модификаций ингредиентов в этой позиции
    field :cart_item_ingredients, as: :has_many, translation_key: "avo.field_translations.cart_item_ingredients"

    # Служебные поля (скрыты в формах редактирования)
    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
