# == Schema Information
#
# Table name: orders
#
#  id           :bigint           not null, primary key
#  amount       :integer
#  cashed       :boolean          default(FALSE)
#  desc         :text(65535)
#  express_no   :string(255)
#  express_type :string(255)
#  no           :string(255)
#  payment_at   :datetime
#  platform     :string(255)
#  receive_at   :datetime
#  send_at      :datetime
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

  class << self
    
    # 收货7天后 钱进入账户
    def set_account
      Order.transaction do 
        self.where(status: 'receive', cashed: 0, prize_log_id: nil).where('receive_at < ?', DateTime.now - 7.days).each do |order|
          unless order.after_order.present?
            order.company.update active_amount: order.company.active_amount.to_i + order.amount, invalid_amount: self.company.invalid_amount.to_i - self.amount
            order.update cashed: 1
          end
        end
      end
      
    end
  end

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
