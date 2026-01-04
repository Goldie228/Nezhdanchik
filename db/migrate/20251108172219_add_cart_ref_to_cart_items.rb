class AddCartRefToCartItems < ActiveRecord::Migration[7.2]
  def change
    # Безопасное добавление связи с корзиной.
    # Проверка column_exists? предотвращает ошибку при повторном запуске миграции (например, при откате и накате).
    add_reference :cart_items, :cart, null: false, foreign_key: true unless column_exists?(:cart_items, :cart_id)
  end
end
