
class Avo::Resources::CartItem < Avo::BaseResource
  self.title = :id
  self.includes = []
  self.translation_key = "avo.resource_translations.cart_item"

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"

    field :cart, as: :belongs_to, translation_key: "avo.field_translations.cart", required: true
    field :dish, as: :belongs_to, translation_key: "avo.field_translations.dish"
    field :quantity, as: :number, translation_key: "avo.field_translations.quantity"
    field :active, as: :boolean, translation_key: "avo.field_translations.active"

    field :cart_item_ingredients, as: :has_many, translation_key: "avo.field_translations.cart_item_ingredients"

    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
