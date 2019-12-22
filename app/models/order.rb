class Order < ApplicationRecord
  include AASM
  belongs_to :user
  belongs_to :company
  has_many :order_products
  before_save :set_values
  has_one :logistic
  belongs_to :address

  STATUS = { wait: '代付款', pay: '代发货', send: '待收货', receive: '已收货'}

  aasm :status do
    state :wait, :initial => true
    state :pay, :send, :receive

    #审核成功 直接上架
    event :do_pay do
      transitions :from => [:wait], :to => :pay
    end

    #审核失败
    event :do_send do
      transitions :from => :pay, :to => :send
    end

    #上架
    event :do_receive do
      transitions :from => :send, :to => :receive
    end
  end

  # 下单
  class << self
    def apply_order user, product_norms, address_id
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
          order = model.new company: company, user: user, address_id: address_id
          order.order_products = order_products
          order.save!
          orders << order
        end
        orders
      rescue => e
        console.log(e.message)
        {error: e.message}
      end
    end

    def prize_order user, product
      order = Order::GameOrder.new user: user, company: product.company
      order_product = OrderProduct.new product: product, number: 1, price: product.price, amount: 1*product.price
      order.order_products = [order_product]
      order.save!
    end
  end

  def set_values
    set_no
    set_amount
  end

  def set_no
    sid = user_id.to_s
    self.no = "#{self.company.no.to_s[0..3] if self.company.present?}#{Time.now.to_i}#{rand(1000..9999).to_s}#{sid.size >= 4 ? sid[0..3] : sid.rjust(4, '0')}"
  end

  def set_amount
    self.order_products.sum :amount
  end


end
