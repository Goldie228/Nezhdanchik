
class Avo::Resources::Order < Avo::BaseResource
  # Используем номер заказа (order_number) вместо ID для более удобного идентификатора в админке
  self.title = :order_number

  # Предзагрузка ассоциаций (user, booking, order_items) для оптимизации скорости загрузки страницы (избегаем N+1)
  self.includes = [ :user, :booking, :order_items ]

  # Ключ для локализации интерфейса
  self.translation_key = "avo.resource_translations.order"

  # Настройка глобального поиска через Ransack
  self.search = {
    query: -> do
      # Позволяет искать по номеру заказа, email пользователя или статусу
      scope.ransack(
        order_number_cont: params[:q],
        user_email_cont: params[:q],
        status_eq: params[:q]
      ).result(distinct: false)
    end
  }

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"

    # Связь с пользователем обязательна
    field :user, as: :belongs_to, required: true, translation_key: "avo.field_translations.user"
    field :booking, as: :belongs_to, translation_key: "avo.field_translations.booking"

    # Номер заказа генерируется автоматически, поэтому только для чтения
    field :order_number, as: :text, required: true, readonly: true, translation_key: "avo.field_translations.order_number"

    # Общая сумма заказа (рассчитывается автоматически)
    field :total_amount, as: :number, required: true, translation_key: "avo.field_translations.total_amount"

    # Выбор статуса заказа из предустановленного списка
    field :status, as: :select,
          options: { pending: "pending", paid: "paid", preparing: "preparing", ready: "ready", completed: "completed", cancelled: "cancelled" },
          translation_key: "avo.field_translations.status"

    # Отображение позиций заказа
    field :order_items, as: :has_many, translation_key: "avo.field_translations.order_items"
    field :dishes, as: :has_many, through: :order_items, translation_key: "avo.field_translations.dishes"

    # Служебные поля времени создания и обновления (скрыты в формах редактирования)
    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
