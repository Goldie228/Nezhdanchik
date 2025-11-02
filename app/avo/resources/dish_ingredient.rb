
class Avo::Resources::DishIngredient < Avo::BaseResource
  self.title = :id
  self.translation_key = "avo.resource_translations.dish_ingredient"

  def fields
    field :id, as: :id
    field :dish, as: :belongs_to
    field :ingredient, as: :belongs_to, searchable: true, attach_scope: -> { Ingredient.available }
    field :default, as: :boolean
  end
end
