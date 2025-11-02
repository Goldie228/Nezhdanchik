
class Avo::Resources::Ingredient < Avo::BaseResource
  self.title = :name
  self.translation_key = "avo.resource_translations.ingredient"

  def fields
    field :id, as: :id
    field :name, as: :text, required: true
    field :price, as: :number
    field :weight, as: :number, translation_key: "avo.field_translations.weight"
    field :available, as: :boolean
    field :allergen, as: :boolean
    field :photo, as: :file, is_image: true, direct_upload: true
    field :dishes, as: :has_many, attach_scope: -> { Dish.active }

    field :nutrition, as: :has_one
  end
end
