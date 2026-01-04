class AddEmailOtpToUsers < ActiveRecord::Migration[7.2]
  def change
    # Хранит код одноразового пароля для двухфакторной аутентификации (2FA)
    add_column :users, :email_otp_code, :string
    # Фиксирует время отправки кода для проверки истечения срока действия (TTL)
    add_column :users, :email_otp_sent_at, :datetime
    # Счетчик неудачных попыток ввода кода для защиты от перебора (brute-force)
    add_column :users, :email_otp_attempts, :integer, default: 0, null: false
    # Флаг активации двухфакторной аутентификации для пользователя
    add_column :users, :two_factor_enabled, :boolean, default: false, null: false

    # Индекс ускоряет поиск пользователя по коду подтверждения при входе
    add_index :users, :email_otp_code
  end
end
