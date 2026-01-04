
class Avo::Resources::Booking < Avo::BaseResource
  # Используем номер брони вместо ID для более понятного заголовка записи
  self.title = :booking_number

  # Жаркая загрузка (Eager Loading) ассоциаций для предотвращения N+1 запросов
  self.includes = [ :user, :seats ]

  # Указываем файл переводов для мультиязычности интерфейса админки
  self.translation_key = "avo.resource_translations.booking"

  # Настройка глобального поиска (Ransack)
  self.search = {
    query: -> do
      # Позволяет искать по номеру брони, email пользователя или статусу
      scope.ransack(
        booking_number_cont: params[:q],
        user_email_cont: params[:q],
        status_eq: params[:q]
      ).result(distinct: false)
    end
  }

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"

    # Связь с пользователем, обязательная для создания брони
    field :user, as: :belongs_to, required: true, translation_key: "avo.field_translations.user"
    field :cart, as: :belongs_to, translation_key: "avo.field_translations.cart"
    field :order, as: :belongs_to, translation_key: "avo.field_translations.order"

    # Номер брони только для чтения (генерируется автоматически)
    field :booking_number, as: :text, required: true, readonly: true, translation_key: "avo.field_translations.booking_number"

    # Время начала и окончания брони (обязательные поля)
    field :starts_at, as: :date_time, required: true, translation_key: "avo.field_translations.starts_at"
    field :ends_at, as: :date_time, required: true, translation_key: "avo.field_translations.ends_at"

    # Выбор типа брони (отдельные места или весь стол) из Enum модели
    field :booking_type, as: :select,
          enum: ::Booking.booking_types,
          display_with_value: true,
          translation_key: "avo.field_translations.booking_type"

    # Требуется ли паспорт для брони
    field :require_passport, as: :boolean, translation_key: "avo.field_translations.require_passport"

    # Статус брони с предустановленными опциями
    field :status, as: :select,
          options: { pending: "pending", confirmed: "confirmed", active: "active", completed: "completed", cancelled: "cancelled" },
          translation_key: "avo.field_translations.status"

    field :total_price, as: :number, translation_key: "avo.field_translations.total_price"
    field :special_requests, as: :textarea, translation_key: "avo.field_translations.special_requests"

    # Связь с местами (через промежуточную таблицу booking_seats)
    field :booking_seats, as: :has_many, translation_key: "avo.field_translations.booking_seats"
    field :seats, as: :has_many, through: :booking_seats, translation_key: "avo.field_translations.seats"

    # Виртуальное поле для отображения названия столика (через места)
    # hide_on: :forms скрывает поле при редактировании, так как оно вычисляемое
    field :table_name, as: :text,
          name: "Столик",
          hide_on: :forms,
          sortable: false,
          translation_key: "avo.field_translations.table" do
      record.table&.name
    end

    # Служебные поля времени создания и обновления (только просмотр)
    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
