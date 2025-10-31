
class Avo::Resources::Dish < Avo::BaseResource
  self.title = :title
  self.includes = [ :category ]

  self.translation_key = "avo.resource_translations.dish"

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"
    field :title, as: :text, required: true, translation_key: "avo.field_translations.title"
    field :description, as: :textarea, translation_key: "avo.field_translations.description"
    field :price, as: :number, required: true, translation_key: "avo.field_translations.price"
    field :slug, as: :text, required: true, translation_key: "avo.field_translations.slug"
    field :active, as: :boolean, default: true, translation_key: "avo.field_translations.active"
    field :cooking_time_minutes, as: :number, translation_key: "avo.field_translations.cooking_time_minutes"

    field :category, as: :belongs_to, translation_key: "avo.field_translations.category"
    field :photos, as: :files, is_image: true, direct_upload: true, multiple: true,
      translation_key: "avo.field_translations.photos"
  end
end
