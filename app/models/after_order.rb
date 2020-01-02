class AfterOrder < ApplicationRecord
  include AASM
  belongs_to :order
  belongs_to :user

  STATUS = { apply: '申请', agree: '已同意', failed: '已拒绝', receive: '已退货待退款', refund: '已退款'}
  EXPRESS = {EMS: 'EMS', STO: '申通', YTO: '圆通', ZTO: '中通', SFEXPRESS: '顺丰', YUNDA: '韵达', TTKDEX: '天天快递', DEPPON: '德邦', HTKY: '汇通快递'}


  aasm :status do
    state :apply, :initial => true
    state :apply, :agree, :failed, :receive, :refund

    #同意
    event :do_agree do
      transitions :from => [:apply], :to => :agree
    end

    #拒绝
    event :do_failed do
      transitions :from => [:apply], :to => :failed
    end

    #发货
    event :do_receive do
      transitions :from => :agree, :to => :receive
    end

    #收货
    event :do_refund do
      transitions :from => [:receive, :agree], :to => :refund
    end
  end


  class << self
    def search_conn params
      after_orders = self.joins(order: {order_products: :product}).order('after_orders.created_at  desc')
      if params[:company_id].present?
        after_orders = after_orders.where('orders.company_id = ?', params[:company_id])
      end
      if params[:name].present?
        after_orders = after_orders.where('products.name like ?', "%#{params[:name]}%")
      end
      if params[:status].present?
        after_orders = after_orders.where('after_orders.status=?', params[:status])
      end
      if params[:order_type].present?
        after_orders = after_orders.where('orders.type=? ', params[:order_type])
      end
      if params[:type].present?
        after_orders = after_orders.where('after_orders.type=? ', params[:type])
      end
      if params[:date_from].present?
        after_orders = after_orders.where('after_orders.created_at >=?', params[:date_from].to_datetime.beginning_of_day)
      end
      if params[:date_to].present?
        after_orders = after_orders.where('after_orders.created_at <?', params[:date_to].to_datetime.end_of_day)
      end
      if params[:no].present?
        after_orders = after_orders.where('orders.no like ?', "%#{params[:no]}%")
      end
      after_orders
    end
  end


  def get_express_type
    EXPRESS[self.express_type.to_sym] if self.express_type.present?
  end

  def get_status
    STATUS[self.status.to_sym] if self.status.present?
  end

  def express
    begin
      r = Express.result self.express_no, nil
      JSON.parse r.body
    rescue => e
      {error: '20001', message: '查询不到信息，请稍后再试'}
    end
  end
end
