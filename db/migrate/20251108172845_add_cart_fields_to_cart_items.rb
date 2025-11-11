class AddCartFieldsToCartItems < ActiveRecord::Migration[7.2]
  def change
    unless column_exists?(:cart_items, :cart_id)
      add_reference :cart_items, :cart, null: false, foreign_key: true, index: true
    end

    unless column_exists?(:cart_items, :quantity)
      add_column :cart_items, :quantity, :integer, null: false, default: 1
    end

    unless column_exists?(:cart_items, :active)
      add_column :cart_items, :active, :boolean, null: false, default: true
    end
  end
end
