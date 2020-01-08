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

class Order < ApplicationRecord
  include AASM
  belongs_to :user
  belongs_to :company
  has_many :order_products
  before_save :set_values
  has_one :logistic
  belongs_to :address
  belongs_to :prize_log
  has_one :after_order
  # has_and_belongs_to_many :payments, join_table: 'order_payments'
  has_many :payments
  STATUS = { wait: '待付款', pay: '待发货', send: '已发货', receive: '已完成', cancel: '已取消'}
  EXPRESS = {EMS: 'EMS', STO: '申通', YTO: '圆通', ZTO: '中通', SFEXPRESS: '顺丰', YUNDA: '韵达', TTKDEX: '天天快递', DEPPON: '德邦', HTKY: '汇通快递'}
  aasm :status do
    state :wait, :initial => true
    state :pay, :send, :receive, :cancel, :apply_after, :after_sale, :after_failed

    #支付
    event :do_pay do
      transitions :from => [:wait], :to => :pay, after: Proc.new{after_pay}
    end

    #取消
    event :do_cancel do
      transitions :from => [:wait], :to => :cancel
    end

    #发货
    event :do_send do
      transitions :from => :pay, :to => :send
    end

    #收货
    event :do_receive do
      transitions :from => :send, :to => :receive
    end

    # #申请售后
    # event :do_after_sale do
    #   transitions :from => [:send, :receive], :to => :after_sale
    # end

    # #售后
    # event :do_after_sale do
    #   transitions :from => :receive, :to => :after_sale
    # end
    #
    # #售后
    # event :do_after_failed do
    #   transitions :from => :apply_after, :to => :after_failed
    # end

  end

  # 下单
  class << self
    def search_conn params
      orders = self.joins(order_products: :product).order('created_at  desc')
      if params[:company_id].present?
        orders = orders.where(company_id: params[:company_id])
      end
      if params[:no].present?
        orders = orders.where('orders.no like ?', "%#{params[:no]}%")
      end
      if params[:name].present?
        orders = orders.where('products.name like ?', "%#{params[:name]}%")
      end
      if params[:status].present?
        orders = orders.where('orders.status=?', params[:status])
      end
      if params[:type].present?
        orders = orders.where('orders.type=? and orders.prize_log_id is null', params[:type])
      end
      if params[:game].present?
        if params[:game] == 1
          orders = orders.where('orders.prize_log_id is not null')
        else
          orders = orders.where('orders.type=? and orders.prize_log_id is null', params[:type])
        end
      end
      if params[:date_from].present?
        orders = orders.where('orders.created_at >=?', params[:date_from].to_datetime.beginning_of_day)
      end
      if params[:date_to].present?
        orders = orders.where('orders.created_at <?', params[:date_to].to_datetime.end_of_day)
      end
      orders
    end

    def search_user_conn params
      orders = self.joins(order_products: :product).order('created_at  desc')
      if params[:type].present?
        if params[:type] == 'Order::GameOrder'
          orders = orders.where('orders.prize_log_id is not null')
        else
          orders = orders.where('orders.type=? and orders.prize_log_id is null', params[:type])
        end
      end
      if params[:status].present?
        orders = orders.where('orders.status=?', params[:status])
      end
      orders
    end


    def apply_order user, product_norms, address_id, desc, platform
      p product_norms, 111
      product_norms ||= JSON.parse [{id: 1, number: 2}, {id: 2, number: 2}, {id: 13, norm: {id: 13, number: 1}}, {id: 12, norm: {id: 11, number: 1}}].to_json
      begin
        company_orders = {}
        orders = []
        if user && product_norms
          order_products = []
          product_norms.each do |product_norm|
            product = Product.where(status: 'up', id: product_norm['id']).first
            raise '找不到这个商品' unless product.present?
            if product.type == 'CoinProduct'
              raise '错误的商品数量数据' if product_norm['number'].to_i < 1
              raise '库存不足' if product_norm['number'].to_i > product.stock
              order_product = OrderProduct.new product: product, number: product_norm['number'], price: product.price, amount: product_norm['number'].to_i * product.price
            else
              norm = product.norms.find_by(id: product_norm['norm']['id'])
              raise '找不到商品规格' unless norm.present?
              raise '错误商品规格' unless product_norm['norm'].present?
              raise '错误的商品数量' if product_norm['norm']['number'].to_i < 1
              raise '库存不足' if product_norm['norm']['number'].to_i > norm.stock
              order_product = OrderProduct.new product: product, number: product_norm['norm']['number'], price: norm.price, amount: product_norm['norm']['number'].to_i * norm.price, norm: norm
            end
            order_products << order_product
            if company_orders[product.company].present?
              company_orders[product.company] = company_orders[product.company] << order_product
            else
              company_orders[product.company] = [order_product]
            end
          end
        else
          raise '错误的请求参数'
        end
        company_orders.each do |company, order_products|
          model = company.present? ? Order::MoneyOrder : Order::CoinOrder
          amount =  order_products.sum{|order_product| order_product.amount}
          order = model.new company: company, user: user, address_id: address_id, amount: amount
          order.order_products = order_products
          order.desc = desc
          order.platform = platform
          order.save!
          orders << order
        end
        orders
      rescue => e
        p e.message
        {error: e.message}
      end
    end

    def prize_order user, product, prize_log
      order_model = product.company.present? ? Order::MoneyOrder : Order::CoinOrder
      order = order_model.new user: user, company: product.company, prize_log: prize_log
      order_product = OrderProduct.new product: product, number: 1, price: product.price, amount: 1*product.price
      order.order_products = [order_product]
      order.save!
    end
  end

  def set_values
    set_no
  end

  def set_no
    sid = user_id.to_s
    self.no = "#{self.company.no.to_s[0..3] if self.company.present?}#{Time.now.to_i}#{rand(1000..9999).to_s}#{sid.size >= 4 ? sid[0..3] : sid.rjust(4, '0')}"
  end

  def after_pay
    self.update payment_at: DateTime.now
    set_sale
    set_stock
  end

  def set_sale
    self.order_products.each do |order_product|
      order_product.product.set_sale order_product.number, order_product.amount
    end
  end


  def view_amount
    if self.type == 'Order::MoneyOrder'
      amount.to_f / 100
    else
      amount
    end
  end

  def number
    self.order_products.sum :number
  end

  def get_express_type
    EXPRESS[self.express_type.to_sym] if self.express_type.present?
  end

  def get_status
    STATUS[self.status.to_sym] if self.status.present?
  end

  def get_status_desc
    case self.status
    when 'pay'
      '商家会快马加鞭给您发出'
    when 'send'
      #{}"#{(DateTime.now - self.payment_at).round}天后将自动确认" if self.payment_at.present?
      '货物已发出，请注意查收'
    when 'receive'
      "非常感谢您的惠顾"
    end
  end


  def current_payment
    payments.last
  end


  def express
    begin
      r = Express.result self.express_no, nil
      JSON.parse r.body
    rescue => e
      {error: '20001', message: '查询不到信息，请稍后再试'}
    end
  end

  def coin
    if self.type == 'Order::MoneyOrder'
      coin = 0
      order_products.each do |order_product|
        p order_product.product.coin, 1111
        coin += order_product.product.coin.to_i * order_product.number
      end
      coin
    else
      0
    end
  end

  def refund_money
    if self.type == 'Order::MoneyOrder'
      self.current_payment.refund_money
    elsif self.type == 'Order::CoinOrder'
      CoinLog.create user: self.user, channel: 'refund', model_id: self.id, coin: self.amount.to_i
      self.after_order.do_refund! if self.after_order.may_do_refund?
    end
  end


end
