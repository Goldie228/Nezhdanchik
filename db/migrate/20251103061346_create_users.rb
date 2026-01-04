class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      # Email используется для авторизации, поэтому null: false
      t.string  :email,       null: false
      # Телефон используется как альтернативный идентификатор или для связи
      t.string  :phone,       null: false
      # Ограничение limit: 255 соответствует стандартному для строк в Rails и предотвращает создание чрезмерно длинных полей
      t.string  :first_name,  null: false, limit: 255
      t.string  :last_name,   null: false, limit: 255
      # Отчество опционально, поэтому без null: false
      t.string  :middle_name, limit: 255
      # Роль пользователя (enum: 0 - customer, 1 - manager, 2 - admin)
      t.integer :role,        default: 0, null: false

      t.timestamps
    end

    # Уникальность email и phone критична для идентификации пользователей и авторизации
    add_index :users, :email, unique: true
    add_index :users, :phone, unique: true
    # Индекс по role ускоряет фильтрацию пользователей по ролям (например, при выборке администраторов)
    add_index :users, :role
  end
end
