class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string  :email,       null: false
      t.string  :phone,       null: false
      t.string  :first_name,  null: false, limit: 255
      t.string  :last_name,   null: false, limit: 255
      t.string  :middle_name, limit: 255
      t.integer :role,        default: 0, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :phone, unique: true
    add_index :users, :role
  end
end
