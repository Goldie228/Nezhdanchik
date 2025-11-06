class AddEmailOtpToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :email_otp_code, :string
    add_column :users, :email_otp_sent_at, :datetime
    add_column :users, :email_otp_attempts, :integer, default: 0, null: false
    add_column :users, :two_factor_enabled, :boolean, default: false, null: false
    add_index :users, :email_otp_code
  end
end
