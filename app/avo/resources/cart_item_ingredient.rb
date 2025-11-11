
class Avo::Resources::CartItemIngredient < Avo::BaseResource
  self.title = :id
  self.includes = []
  self.translation_key = "avo.resource_translations.cart_item_ingredient"

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"

    field :cart_item, as: :belongs_to, translation_key: "avo.field_translations.cart_item", required: true
    field :ingredient, as: :belongs_to, translation_key: "avo.field_translations.ingredient", required: true
    field :included, as: :boolean, translation_key: "avo.field_translations.included"
    field :default_in_dish, as: :boolean, translation_key: "avo.field_translations.default"
    field :price, as: :number, translation_key: "avo.field_translations.price"

    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
