
class Avo::Resources::Category < Avo::BaseResource
  # Используем имя категории в качестве заголовка записи в интерфейсе
  self.title = :name

  # Подключаем связанные блюда (dishes) для оптимизации запросов (избегаем N+1 проблемы)
  self.includes = [ :dishes ]

  # Указываем ключ переводов для локализации интерфейса админки
  self.translation_key = "avo.resource_translations.category"

  def fields
    field :id, as: :id, translation_key: "avo.field_translations.id"
    field :name, as: :text, required: true, translation_key: "avo.field_translations.name"
    field :slug, as: :text, required: true, translation_key: "avo.field_translations.slug"
    field :description, as: :textarea, translation_key: "avo.field_translations.description"

    # Поле активации категории. Default: true упрощает создание новых категорий.
    field :active, as: :boolean, default: true, translation_key: "avo.field_translations.active"

    # Поле для загрузки изображения (ActiveStorage).
    # direct_upload позволяет загружать файлы напрямую в S3/Storage, минуя сервер приложения.
    field :photo, as: :file, is_image: true, direct_upload: true,
      translation_key: "avo.field_translations.photo"

    field :dishes, as: :has_many, translation_key: "avo.field_translations.dishes"
  end
end
