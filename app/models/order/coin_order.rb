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

class Order::CoinOrder < Order
  validate :must_can_buy
  after_create :set_pay

  def must_can_buy
    errors.add(:amount, '金币不足') if user.coin < amount.to_i && self.prize_log.blank?
  end

  def set_pay
    if self.prize_log.present?
      self.do_pay!
    else
      if self.may_do_pay?
        self.user.coin_logs.create channel: 'order', model_id: self.id, coin: self.amount - 2*self.amount
        self.do_pay!
      end
    end

  end

  def set_stock
    self.order_products.each do |order_product|
      order_product.product.update stock: order_product.product.stock - order_product.number
    end
  end
end
