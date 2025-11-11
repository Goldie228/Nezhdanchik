class AddCartRefToCartItems < ActiveRecord::Migration[7.2]
  def change
    add_reference :cart_items, :cart, null: false, foreign_key: true unless column_exists?(:cart_items, :cart_id)
  end
end
