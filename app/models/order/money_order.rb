class Order::MoneyOrder < Order
  after_create :set_payment

  def set_payment
    unless self.prize_log_id.present?
      self.payments.create amount: self.amount, user: self.user
    end
  end
end