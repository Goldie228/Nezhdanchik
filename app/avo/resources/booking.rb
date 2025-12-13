class Avo::Resources::Booking < Avo::BaseResource
  self.title = :booking_number
  self.includes = [ :user, :seats ]
  self.translation_key = "avo.resource_translations.booking"

  self.search = {
    query: -> do
      scope.ransack(
        booking_number_cont: params[:q],
        user_email_cont: params[:q],
        status_eq: params[:q]
      ).result(distinct: false)
    end
  }

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"
    field :user, as: :belongs_to, required: true, translation_key: "avo.field_translations.user"
    field :cart, as: :belongs_to, translation_key: "avo.field_translations.cart"
    field :order, as: :belongs_to, translation_key: "avo.field_translations.order"

    field :booking_number, as: :text, required: true, readonly: true, translation_key: "avo.field_translations.booking_number"
    field :starts_at, as: :date_time, required: true, translation_key: "avo.field_translations.starts_at"
    field :ends_at, as: :date_time, required: true, translation_key: "avo.field_translations.ends_at"

    field :booking_type, as: :select,
          enum: ::Booking.booking_types,
          display_with_value: true,
          translation_key: "avo.field_translations.booking_type"

    field :require_passport, as: :boolean, translation_key: "avo.field_translations.require_passport"
    field :status, as: :select,
          options: { pending: "pending", confirmed: "confirmed", active: "active", completed: "completed", cancelled: "cancelled" },
          translation_key: "avo.field_translations.status"

    field :total_price, as: :number, translation_key: "avo.field_translations.total_price"
    field :special_requests, as: :textarea, translation_key: "avo.field_translations.special_requests"

    field :booking_seats, as: :has_many, translation_key: "avo.field_translations.booking_seats"
    field :seats, as: :has_many, through: :booking_seats, translation_key: "avo.field_translations.seats"

    field :table_name, as: :text,
          name: "Столик",
          hide_on: :forms,
          sortable: false,
          translation_key: "avo.field_translations.table" do
      record.table&.name
    end

    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
