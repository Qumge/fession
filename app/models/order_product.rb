# == Schema Information
#
# Table name: order_products
#
#  id         :bigint           not null, primary key
#  amount     :integer
#  number     :integer
#  price      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  norm_id    :integer
#  order_id   :integer
#  product_id :integer
#

class OrderProduct < ApplicationRecord
  belongs_to :product
  belongs_to :order
  belongs_to :norm


  def view_price
    if product.type == 'MoneyProduct'
      price.to_f / 100
    else
      price
    end
  end

  def view_amount
    if product.type == 'MoneyProduct'
      amount.to_f / 100
    else
      amount
    end
  end
end
