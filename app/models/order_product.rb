class OrderProduct < ApplicationRecord
  belongs_to :product
  belongs_to :order
  belongs_to :norm


  def view_price
    if product.type == 'Product::MoneyProduct'
      price.to_f / 100
    else
      price
    end
  end

  def view_amount
    if product.type == 'Product::MoneyProduct'
      amount.to_f / 100
    else
      amount
    end
  end
end
