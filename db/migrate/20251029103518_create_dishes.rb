class CreateDishes < ActiveRecord::Migration[7.2]
  def change
    create_table :dishes do |t|
      # Название блюда (обязательное поле)
      t.string  :title, null: false

      # Описание блюда (состав, особенности)
      t.text    :description

      # Цена блюда с точностью до копеек (обязательное поле)
      t.decimal :price, precision: 10, scale: 2, null: false

      # Уникальный slug для SEO‑ссылок и человеко‑читаемых URL
      t.string  :slug, null: false

      # Флаг активности (показывать/скрывать блюдо в меню)
      t.boolean :active, default: true

      # Время приготовления в минутах (для отображения пользователю)
      t.integer :cooking_time_minutes

      t.timestamps
    end

    # Индекс для быстрого поиска по slug и обеспечения уникальности
    add_index :dishes, :slug, unique: true

    # Индекс для фильтрации по активности (активные/неактивные блюда)
    add_index :dishes, :active

    # Индекс для сортировки и выборки по цене
    add_index :dishes, :price
  end
end
