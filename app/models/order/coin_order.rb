class Order::CoinOrder < Order
  validate :must_can_buy
  after_create :set_pay

  def must_can_buy
    errors.add(:amount, '金币不足') if user.coin < amount
  end

  def set_pay
    if self.may_do_pay?
      self.user.coin_logs.create channel: 'order', model_id: self.id, coin: self.amount - 2*self.amount
      self.do_pay!
    end
  end

  def set_stock
    self.order_products.each do |order_product|
      order_product.product.update stock: order_product.product.stock - order_product.number
    end
  end
end