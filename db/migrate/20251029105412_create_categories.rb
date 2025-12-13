class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      # Название категории (обязательное поле)
      t.string :name, null: false

      # Описание категории (опционально)
      t.text :description

      # Уникальный slug для friendly_id и SEO‑ссылок
      t.string :slug, null: false

      # Флаг активности (показывать/скрывать категорию)
      t.boolean :active, default: true

      t.timestamps
    end

    # Индексы
    add_index :categories, :slug, unique: true
  end
end
