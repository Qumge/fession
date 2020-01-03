# == Schema Information
#
# Table name: orders
#
#  id           :bigint           not null, primary key
#  amount       :integer
#  desc         :text(65535)
#  express_no   :string(255)
#  express_type :string(255)
#  no           :string(255)
#  payment_at   :datetime
#  platform     :string(255)
#  status       :string(255)
#  type         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  address_id   :integer
#  company_id   :integer
#  prize_log_id :integer
#  user_id      :integer
#

class Order::MoneyOrder < Order
  after_create :set_payment

  def set_payment
    unless self.prize_log_id.present?
      self.payments.create amount: self.amount, user: self.user
    end
  end

  def set_stock
    self.order_products.each do |order_product|
      order_product.norm.update stock: order_product.norm.stock - order_product.number
    end
  end

end
