
class Avo::Resources::Table < Avo::BaseResource
  # Используем название стола как заголовок записи в админке
  self.title = :name

  # Список ассоциаций для предварительной загрузки (пока пуст, так как связанных объектов на индексе нет)
  self.includes = []

  # Ключ для локализации интерфейса админки
  self.translation_key = "avo.resource_translations.table"

  # Настройка поиска по названию или ID
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

    # Название стола (например, "У окна" или "VIP-1")
    field :name, as: :text, required: true, translation_key: "avo.field_translations.name"

    # Количество мест (посадочных) за столом
    field :seats_count, as: :number, required: true, translation_key: "avo.field_translations.seats_count"

    # Базовая цена за бронирование стола целиком (если используется)
    field :booking_price, as: :number, required: true, translation_key: "avo.field_translations.booking_price"

    # Флаг активности позволяет скрыть стол без удаления его из базы
    field :active, as: :boolean, translation_key: "avo.field_translations.active"

    # Связь с физическими местами
    field :seats, as: :has_many, translation_key: "avo.field_translations.seats"

    # Связь с бронированиями через промежуточную таблицу
    field :booking_seats, as: :has_many, translation_key: "avo.field_translations.booking_seats"
    field :bookings, as: :has_many, through: :booking_seats, translation_key: "avo.field_translations.bookings"

    # Служебные поля времени (скрыты в формах редактирования)
    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
