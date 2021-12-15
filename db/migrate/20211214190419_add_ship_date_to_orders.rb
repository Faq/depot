class AddShipDateToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :ship_date, :date
  end
end
