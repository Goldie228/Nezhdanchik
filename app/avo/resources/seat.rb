
class Avo::Resources::Seat < Avo::BaseResource
  # Используем номер места как заголовок, так как это его основной идентификатор
  self.title = :number

  # Подгружаем связанный стол (table) для избежания N+1 запросов при отображении
  self.includes = [ :table ]

  # Ключ для локализации интерфейса админки
  self.translation_key = "avo.resource_translations.seat"

  # Настройка поиска по номеру места или названию стола
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

    # Место обязательно должно относиться к какому-то столу
    field :table, as: :belongs_to, required: true, translation_key: "avo.field_translations.table"
    field :number, as: :number, required: true, translation_key: "avo.field_translations.number"

    # Флаг активности позволяет временно скрыть место (например, на ремонт)
    field :active, as: :boolean, translation_key: "avo.field_translations.active"

    # Связь с бронированиями через промежуточную таблицу booking_seats
    field :booking_seats, as: :has_many, translation_key: "avo.field_translations.booking_seats"
    field :bookings, as: :has_many, through: :booking_seats, translation_key: "avo.field_translations.bookings"

    # Служебные поля времени (скрыты в формах редактирования)
    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
