class CreateCarts < ActiveRecord::Migration[7.2]
  def change
    create_table :carts do |t|
      # Связь корзины с пользователем. unique: true гарантирует, что у пользователя может быть только одна корзина.
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
