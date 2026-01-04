class AddPasswordDigestToUsers < ActiveRecord::Migration[7.2]
  def change
    # Добавляет поле для хранения хеша пароля (используется gem bcrypt).
    # Пароль никогда не хранится в открытом виде, только digest (хеш).
    add_column :users, :password_digest, :string, null: false
  end
end
