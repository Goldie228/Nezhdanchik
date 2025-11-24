
class Avo::Resources::Table < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.translation_key = "avo.resource_translations.table"

  self.search = {
    query: -> do
      scope.ransack(
        name_cont: params[:q],
        id_eq: params[:q]
      ).result(distinct: false)
    end
  }

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"
    field :name, as: :text, required: true, translation_key: "avo.field_translations.name"
    field :seats_count, as: :number, required: true, translation_key: "avo.field_translations.seats_count"
    field :booking_price, as: :number, required: true, translation_key: "avo.field_translations.booking_price"
    field :active, as: :boolean, translation_key: "avo.field_translations.active"

    field :seats, as: :has_many, translation_key: "avo.field_translations.seats"
    field :booking_seats, as: :has_many, translation_key: "avo.field_translations.booking_seats"
    field :bookings, as: :has_many, through: :booking_seats, translation_key: "avo.field_translations.bookings"

    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
