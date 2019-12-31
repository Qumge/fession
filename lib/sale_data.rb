class SaleData
  def initialize args = {}
    @date_from = args[:date_from]
    @date_from ||= (DateTime.now-6.days).beginning_of_day
    @date_to = args[:date_to]
    @date_to ||= DateTime.now.end_of_day
    @company_id = args[:company_id]
  end

  def date_headers
    (@date_from..@date_to).collect {|date| date.strftime '%Y-%m-%d'}
  end

  def apply_data
    data_scope.where('orders.status = ? or orders.status = ?', 'wait', 'apply').where(search_conn 'apply')
  end

  def pay_data
    data_scope.where('orders.status != ? or orders.status != ?', 'wait', 'apply').where(search_conn)
  end

  def select
    'sum(order_products.amount) as total_amount, count(orders.id) as order_number, orders.user_id as user_id, sum(distinct(order_products.number)) as product_number'
  end

  def data_scope
    OrderProduct.joins(order: :user)
  end

  def search_conn type='payment'
    if type == 'apply'
      time = 'created_at'
    else
      time = 'payment_at'
    end
    search = ["orders.type = 'Order::MoneyOrder' and orders.#{time} >= '#{@date_from}' and orders.#{time} < '#{@date_to}'"]
    if @company_id.present?
      search << "orders.company_id = #{@company_id}"
    end
    search.join ' and '
  end

  def date_group_data data
    data.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
  end


  def total_data
    # 下单数量
    apply_order_number = apply_data.count('distinct(orders.id)')
    # 下单人数
    apply_user_number = apply_data.count('distinct(orders.user_id)')

    # 交易金额
    pay_total_amount = pay_data.sum('order_products.amount').to_f / 100
    # 支付单数量
    pay_order_number = pay_data.count('distinct(orders.id)')
    #支付人数
    pay_user_number = pay_data.count('distinct(orders.user_id)')
    # 交易商品数量
    pay_product_number = pay_data.sum('order_products.number')
    header_datas = [{name: '下单数量', data: apply_order_number}, {name: '下单人数', data: apply_user_number}, {name: '交易金额', data: pay_total_amount},
    {name: '支付单数量', data: pay_order_number}, {name: '支付人数', data: pay_user_number}, {name: '交易商品数量', data: pay_product_number}]
  end


  def data
    return total_data, date_headers, chart_data, table_data
  end


  def chart_data
    apply_records = apply_data.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
    pay_records = pay_data.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
    datas = []
    #下单数量
    apply_order_number = []
    apply_user_number = []

    pay_total_amount = []
    pay_order_number = []
    pay_user_number = []
    pay_product_number = []


    date_headers.each do |date|
      # 下单数量
      apply_order_number << (apply_records[date].present? ? apply_records[date].uniq{|order_product| order_product.order_id}.size : 0)
      # 下单人数
      apply_user_number << (apply_records[date].present? ? apply_records[date].uniq{|order_product| order_product.order.user_id}.size : 0)
    end

    p pay_records, 111
    date_headers.each do |date|
      p pay_records[date], 11122
      # 交易金额
      pay_total_amount << (pay_records[date].present? ? pay_records[date].sum{|order_product| order_product.amount}.to_f / 100 : 0)
      # 支付单数量
      pay_order_number << (pay_records[date].present? ? pay_records[date].uniq{|order_product| order_product.order_id}.size : 0)
      #支付人数
      pay_user_number << (pay_records[date].present? ? pay_records[date].uniq{|order_product| order_product.order.user_id}.size : 0)
      # 交易商品数量
      pay_product_number << (pay_records[date].present? ? pay_records[date].sum{|order_product| order_product.number}  : 0)
    end


    [{name: '下单数量', data: apply_order_number}, {name: '下单人数', data: apply_user_number}, {name: '交易金额', data: pay_total_amount},
     {name: '支付单数量', data: pay_order_number}, {name: '支付人数', data: pay_user_number}, {name: '交易商品数量', data: pay_product_number} ]
  end


  def table_data
    apply_records = apply_data.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
    pay_records = pay_data.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
    date_datas = []
    date_headers.each do |date|
      apply_data = apply_records[date]
      pay_data = pay_records[date]
      datas = []
      p apply_data, 111
      p apply_data.count('distinct(orders.id)') if apply_data.present?

      datas << {name: '下单数量', data: apply_data.blank? ? 0 : apply_data.count('distinct(orders.id)')}
      datas << {name: '下单人数', data: apply_data.blank? ? 0 : apply_data.count('distinct(orders.user_id)')}

      datas << {name: '交易金额', data: pay_data.blank? ? 0 : pay_data.sum{|data| data.amount}.to_f/100}
      datas << {name: '支付人数', data: pay_data.blank? ? 0 : pay_data.count('distinct(orders.id)')}
      datas << {name: '支付单数量', data: pay_data.blank? ? 0 : pay_data.count('distinct(orders.user_id)')}
      datas << {name: '交易商品数', data: pay_data.blank? ? 0 : pay_data.sum{|data| data.number}}

      date_datas << [date, datas]
    end
    date_datas
  end






end