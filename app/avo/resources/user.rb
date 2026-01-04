
class Avo::Resources::User < Avo::BaseResource
  # Используем email как заголовок записи, так как он уникален и информативен
  self.title = :email

  # Список ассоциаций для предварительной загрузки (пока пуст)
  self.includes = []

  # Ключ для локализации интерфейса админки
  self.translation_key = "avo.resource_translations.user"

  # Глобальный поиск по основным идентификаторам пользователя
  self.search = {
    query: -> do
      scope.ransack(
        email_cont: params[:q],
        phone_cont: params[:q],
        first_name_cont: params[:q],
        last_name_cont: params[:q]
      ).result(distinct: false)
    end
  }

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"

    # Email используется как основной логин, поэтому обязателен
    field :email, as: :text, required: true, translation_key: "avo.field_translations.email"

    # Телефон как альтернативный способ связи
    field :phone, as: :text, required: true, translation_key: "avo.field_translations.phone"

    # ФИО пользователя
    field :first_name, as: :text, required: true, translation_key: "avo.field_translations.first_name"
    field :last_name, as: :text, required: true, translation_key: "avo.field_translations.last_name"
    field :middle_name, as: :text, translation_key: "avo.field_translations.middle_name"

    # Роль пользователя (enum) для разграничения прав доступа
    field :role, as: :select, enum: ::User.roles, display_with_value: true, translation_key: "avo.field_translations.role"

    # Поля пароля отображаются только на формах (only_on: :forms) для безопасности
    field :password, as: :password, required: true, only_on: :forms, translation_key: "avo.field_translations.password"
    field :password_confirmation, as: :password, required: true, only_on: :forms, translation_key: "avo.field_translations.password_confirmation"

    # Служебные поля времени создания и обновления (скрыты в формах редактирования)
    field :created_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.created_at"
    field :updated_at, as: :date_time, hide_on: :forms, translation_key: "avo.field_translations.updated_at"
  end
end
