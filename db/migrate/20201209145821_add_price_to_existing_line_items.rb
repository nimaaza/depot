class AddPriceToExistingLineItems < ActiveRecord::Migration[6.0]
  def up
    LineItem.all.each do |line_item|
      price = line_item.product.price * line_item.quantity
      line_item.update(price: price)
    end
  end
end
