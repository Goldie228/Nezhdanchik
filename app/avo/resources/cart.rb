
class Avo::Resources::Cart < Avo::BaseResource
  # Используем ID как заголовок, так как корзина — внутренняя сущность, не имеющая названия
  self.title = :id

  # Список ассоциаций для предварительной загрузки (пока пуст)
  self.includes = []

  # Указываем файл переводов для мультиязычности интерфейса админки
  self.translation_key = "avo.resource_translations.cart"

  # Настройка поиска через Ransack
  self.search = {
    query: -> do
      # Позволяет найти корзину по email владельца
      scope.ransack(
        user_email_cont: params[:q],
      ).result(distinct: false)
    end
  }

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"

    # Связь с пользователем обязательна
    field :user, as: :belongs_to, translation_key: "avo.field_translations.user", required: true

    # Отображение товаров внутри корзины
    field :cart_items, as: :has_many, translation_key: "avo.field_translations.cart_items"

    # Служебные поля времени создания и обновления (только просмотр)
    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
