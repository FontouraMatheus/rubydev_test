class FixTotalPriceDefaultInCarts < ActiveRecord::Migration[7.1]
  def up
    change_column_default :carts, :total_price, 0.0
    execute "UPDATE carts SET total_price = 0.0 WHERE total_price IS NULL"
    change_column_null :carts, :total_price, false
  end

  def down
    change_column_null :carts, :total_price, true
    change_column_default :carts, :total_price, nil
  end
end
