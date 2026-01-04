class CreateActiveStorageTables < ActiveRecord::Migration[7.0]
  def change
    # Определяем типы ключей (bigint или uuid) на основе конфигурации Rails для совместимости
    primary_key_type, foreign_key_type = primary_and_foreign_key_types

    # Таблица для хранения метаданных о загруженных файлах (изображения, документы)
    create_table :active_storage_blobs, id: primary_key_type do |t|
      t.string   :key,          null: false
      t.string   :filename,     null: false
      t.string   :content_type
      t.text     :metadata
      t.string   :service_name, null: false # Например, 'local' или 'amazon'
      t.bigint   :byte_size,    null: false # Размер файла в байтах
      t.string   :checksum

      if connection.supports_datetime_with_precision?
        t.datetime :created_at, precision: 6, null: false
      else
        t.datetime :created_at, null: false
      end

      # Индекс по key обеспечивает быстрый поиск файла при отдаче контента
      t.index [ :key ], unique: true
    end

    # Таблица связывает файлы (blobs) с моделями приложения (User, Dish и т.д.)
    create_table :active_storage_attachments, id: primary_key_type do |t|
      t.string     :name,     null: false # Название ассоциации в модели (например, 'photo' или 'avatar')
      # Полиморфная связь позволяет прикреплять файлы к любой модели
      t.references :record,   null: false, polymorphic: true, index: false, type: foreign_key_type
      t.references :blob,     null: false, type: foreign_key_type

      if connection.supports_datetime_with_precision?
        t.datetime :created_at, precision: 6, null: false
      else
        t.datetime :created_at, null: false
      end

      # Составной уникальный индекс предотвращает дублирование файлов для одной записи
      t.index [ :record_type, :record_id, :name, :blob_id ], name: :index_active_storage_attachments_uniqueness, unique: true
      t.foreign_key :active_storage_blobs, column: :blob_id
    end

    # Таблица для хранения вариантов изображений (например, миниатюры или обрезанные версии)
    create_table :active_storage_variant_records, id: primary_key_type do |t|
      t.belongs_to :blob, null: false, index: false, type: foreign_key_type
      t.string :variation_digest, null: false # Хэш для идентификации конкретного варианта трансформации

      t.index [ :blob_id, :variation_digest ], name: :index_active_storage_variant_records_uniqueness, unique: true
      t.foreign_key :active_storage_blobs, column: :blob_id
    end
  end

  private
    # Вспомогательный метод для получения типов ключей из конфигурации генераторов
    def primary_and_foreign_key_types
      config = Rails.configuration.generators
      setting = config.options[config.orm][:primary_key_type]
      primary_key_type = setting || :primary_key
      foreign_key_type = setting || :bigint
      [ primary_key_type, foreign_key_type ]
    end
end
