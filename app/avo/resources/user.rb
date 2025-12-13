class Avo::Resources::User < Avo::BaseResource
  self.title = :email
  self.includes = []
  self.translation_key = "avo.resource_translations.user"

  self.search = {
    query: -> do
      scope.ransack(
        email_cont: params[:q],
        phone_cont: params[:q],
        first_name_cont: params[:q],
        last_name_cont: params[:q]
      ).result(distinct: false)
    end
  }

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"
    field :email, as: :text, required: true, translation_key: "avo.field_translations.email"
    field :phone, as: :text, required: true, translation_key: "avo.field_translations.phone"
    field :first_name, as: :text, required: true, translation_key: "avo.field_translations.first_name"
    field :last_name, as: :text, required: true, translation_key: "avo.field_translations.last_name"
    field :middle_name, as: :text, translation_key: "avo.field_translations.middle_name"
    field :role, as: :select, enum: ::User.roles, display_with_value: true, translation_key: "avo.field_translations.role"

    field :password, as: :password, required: true, only_on: :forms, translation_key: "avo.field_translations.password"
    field :password_confirmation, as: :password, required: true, only_on: :forms, translation_key: "avo.field_translations.password_confirmation"

    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
