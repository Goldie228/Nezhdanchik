
class Avo::Resources::Category < Avo::BaseResource
  self.title = :name
  self.includes = [ :dishes ]

  self.translation_key = "avo.resource_translations.category"

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"
    field :name, as: :text, required: true, translation_key: "avo.field_translations.name"
    field :slug, as: :text, required: true, translation_key: "avo.field_translations.slug"
    field :description, as: :textarea, translation_key: "avo.field_translations.description"
    field :active, as: :boolean, default: true, translation_key: "avo.field_translations.active"

    field :photo, as: :file, is_image: true, direct_upload: true,
      translation_key: "avo.field_translations.photo"

    field :dishes, as: :has_many, translation_key: "avo.field_translations.dishes"
  end
end
