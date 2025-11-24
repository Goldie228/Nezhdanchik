
class Avo::Resources::Seat < Avo::BaseResource
  self.title = :number
  self.includes = [ :table ]
  self.translation_key = "avo.resource_translations.seat"

  self.search = {
    query: -> do
      scope.ransack(
        number_eq: params[:q],
        table_name_cont: params[:q]
      ).result(distinct: false)
    end
  }

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"
    field :table, as: :belongs_to, required: true, translation_key: "avo.field_translations.table"
    field :number, as: :number, required: true, translation_key: "avo.field_translations.number"
    field :active, as: :boolean, translation_key: "avo.field_translations.active"

    field :booking_seats, as: :has_many, translation_key: "avo.field_translations.booking_seats"
    field :bookings, as: :has_many, through: :booking_seats, translation_key: "avo.field_translations.bookings"

    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
