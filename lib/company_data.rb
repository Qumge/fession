class CompanyData
  def initialize args = {}
    @date_from = args[:date_from]
    @date_from ||= (DateTime.now-6.days).beginning_of_day
    @date_to = args[:date_to]
    @date_to ||= DateTime.now.end_of_day
  end

  def date_headers
    (@date_from..@date_to).collect {|date| date.strftime '%Y-%m-%d'}
  end


  # 新增商户
  def new_companies
    Company.where(created_at: @date_from..@date_to)
  end

  # 发布任务商户
  def task_companies
    Task.joins(:company).where('tasks.created_at >= ? and tasks.updated_at < ?', @date_from, @date_to)
    # FissionLog.joins(task: :company).where('fission_logs.created_at >= ? and fission_logs.updated_at < ?', @date_from, @date_to)
  end


  # 交易商户
  def order_companies
    Order::MoneyOrder.joins(:company).where('orders.payment_at >= ? and orders.payment_at < ?', @date_from, @date_to)
  end






  def total_data
    [{name: '新增商户', data: new_companies.size}, {name: '发布任务商户', data: task_companies.uniq{|task| task.company_id}.size},
    {name: '交易商户', data: order_companies.uniq{|order| order.company_id}.size}]
  end


  def data
    return total_data, date_headers, chart_data, table_data
  end


  def chart_data
    new_companies_records = new_companies.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
    task_companies_records = task_companies.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
    order_companies_records = order_companies.group_by{|record| record.payment_at.strftime '%Y-%m-%d'}


    new_companies_number = []
    task_companies_number = []
    order_companies_number = []
    date_headers.each do |date|
      # 新增商户
      new_companies_number << (new_companies_records[date].present? ? new_companies_records[date].size : 0)
      # 任务商户
      task_companies_number << (task_companies_records[date].present? ? task_companies_records[date].uniq{|task| task.company_id}.size : 0)
      # 交易商户
      order_companies_number << (order_companies_records[date].present? ? order_companies_records[date].uniq{|order| order.company_id}.size : 0)
    end

    [{name: '新增商户', data: new_companies_number}, {name: '任务商户', data: task_companies_number},
     {name: '交易商户', data: order_companies_number}]
  end


  def table_data
    new_companies_records = new_companies.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
    task_companies_records = task_companies.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
    order_companies_records = order_companies.group_by{|record| record.payment_at.strftime '%Y-%m-%d'}
    date_datas = []
    date_headers.each do |date|
      new_companies_data = new_companies_records[date]
      task_companies_data = task_companies_records[date]
      order_companies_data = order_companies_records[date]
      datas = []

      datas << {name: '新增商户', data: new_companies_data.blank? ? 0 : new_companies_data.size}
      datas << {name: '发布任务商户数', data: task_companies_data.blank? ? 0 : task_companies_data.uniq{|task| task.company_id}.size }
      datas << {name: '交易商户', data: order_companies_data.blank? ? 0 : order_companies_data.uniq{|order| order.company_id}.size}

      date_datas << {date => datas}
    end
    date_datas
  end






end