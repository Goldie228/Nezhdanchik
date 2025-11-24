
class Avo::Resources::Order < Avo::BaseResource
  self.title = :order_number
  self.includes = [ :user, :booking, :order_items ]
  self.translation_key = "avo.resource_translations.order"

  self.search = {
    query: -> do
      scope.ransack(
        order_number_cont: params[:q],
        user_email_cont: params[:q],
        status_eq: params[:q]
      ).result(distinct: false)
    end
  }

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"
    field :user, as: :belongs_to, required: true, translation_key: "avo.field_translations.user"
    field :booking, as: :belongs_to, translation_key: "avo.field_translations.booking"

    field :order_number, as: :text, required: true, readonly: true, translation_key: "avo.field_translations.order_number"
    field :total_amount, as: :number, required: true, translation_key: "avo.field_translations.total_amount"
    field :status, as: :select,
          options: { pending: "pending", paid: "paid", preparing: "preparing", ready: "ready", completed: "completed", cancelled: "cancelled" },
          translation_key: "avo.field_translations.status"

    field :order_items, as: :has_many, translation_key: "avo.field_translations.order_items"
    field :dishes, as: :has_many, through: :order_items, translation_key: "avo.field_translations.dishes"

    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
