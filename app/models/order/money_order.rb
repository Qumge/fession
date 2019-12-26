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