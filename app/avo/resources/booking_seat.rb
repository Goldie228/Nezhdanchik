
class Avo::Resources::BookingSeat < Avo::BaseResource
  self.title = :id
  self.includes = [ :booking, :seat ]
  self.translation_key = "avo.resource_translations.booking_seat"

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"
    field :booking, as: :belongs_to, required: true, translation_key: "avo.field_translations.booking"
    field :seat, as: :belongs_to, required: true, translation_key: "avo.field_translations.seat"

    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
