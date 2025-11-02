
class Avo::Resources::Nutrition < Avo::BaseResource
  self.title = :id

  def fields
    field :id, as: :id
    field :proteins, as: :number, translation_key: "avo.field_translations.proteins"
    field :fats, as: :number, translation_key: "avo.field_translations.fats"
    field :carbohydrates, as: :number, translation_key: "avo.field_translations.carbohydrates"
  end
end
