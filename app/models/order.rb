class Order < ApplicationRecord
  belongs_to :user
  belongs_to :company
  has_many :order_products

  # 下单
  class << self
    def apply_order user, product_norms
      product_norms = [{id: 1, norm: {id: 1, number: 1}, number: 1}]
      begin
        if user && product_norms
          orders = {}
          product_norms.each do |product_norm|
            product = Product.where(status: 'on', id: product['id']).first
            raise '找不到这个商品' unless product.present?
            if product.type == 'CoinProduct'
              raise '错误的数据' if product_norm['number'].to_i < 1
              order_product = OrderProduct.new product: product, number: product_norm['number'], price: product.price, amount: product_norm['number'].to_i * product.price
            else
              raise '错误的norm' unless product_norm['norm'].present?
              raise '错误的商品数量' if product_norm['norm']['number'].to_i < 1
              norm = product.norms.where(id: product_norm['norm']['id'])
              raise '错误的norm' unless norm.present?
              order_product = OrderProduct.new product: product, number: product_norm['norm']['number'], price: norm.price, amount: product_norm['norm']['number'].to_i * norm.price
            end
            if orders[product.company].present?
              orders[product.company] = orders[product.company] << order_product
            else
              orders[product.company] = [order_product]
            end
          end
        end
      rescue => e
        p e.message
      end
    end
  end


end
