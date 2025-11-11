
class Avo::Resources::Cart < Avo::BaseResource
  self.title = :id
  self.includes = []
  self.translation_key = "avo.resource_translations.cart"

  self.search = {
    query: -> do
      scope.ransack(
        user_email_cont: params[:q],
      ).result(distinct: false)
    end
  }

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"
    field :user, as: :belongs_to, translation_key: "avo.field_translations.user", required: true

    field :cart_items, as: :has_many, translation_key: "avo.field_translations.cart_items"

    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
