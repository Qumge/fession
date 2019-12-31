class UserData
  def initialize args = {}
    @date_from = args[:date_from]
    @date_from ||= (DateTime.now-6.days).beginning_of_day
    @date_to = args[:date_to]
    @date_to ||= DateTime.now.end_of_day
  end

  def date_headers
    (@date_from..@date_to).collect {|date| date.strftime '%Y-%m-%d'}
  end


  # 新增用户
  def new_users
    User.where(created_at: @date_from..@date_to)
  end

  # 任务用户
  def task_users
    FissionLog.joins(:user).where('fission_logs.created_at >= ? and fission_logs.updated_at < ?', @date_from, @date_to)
  end

  # 活跃用户
  def active_users
    User.where(last_active_at: @date_from..@date_to)
  end

  # 交易用户
  def order_users
    Order::MoneyOrder.joins(:user).where('orders.payment_at >= ? and orders.payment_at < ?', @date_from, @date_to)
  end






  def total_data
    [{name: '新增用户', data: new_users.size}, {name: '任务用户', data: task_users.uniq{|fission_log| fission_log.user_id}.size},
                    {name: '活跃用户', data: active_users.size}, {name: '交易用户', data: order_users.uniq{|order| order.user_id}.size}]
  end


  def data
    return total_data, date_headers, chart_data, table_data
  end


  def chart_data
    new_users_records = new_users.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
    task_users_records = task_users.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
    active_users_records = active_users.group_by{|record| record.last_active_at.strftime '%Y-%m-%d'}
    order_users_records = order_users.group_by{|record| record.payment_at.strftime '%Y-%m-%d'}


    new_users_number = []
    task_users_number = []
    active_users_number = []
    order_users_number = []
    date_headers.each do |date|
      # 新增用户
      new_users_number << (new_users_records[date].present? ? new_users_records[date].size : 0)
      # 任务用户
      task_users_number << (task_users_records[date].present? ? task_users_records[date].uniq{|fission_log| fission_log.user_id}.size : 0)
      # 活跃
      active_users_number << (active_users_records[date].present? ? active_users_records[date].size : 0)
      # 交易用户
      order_users_number << (order_users_records[date].present? ? order_users_records[date].uniq{|order| order.user_id}.size : 0)
    end

    [{name: '新增用户', data: new_users_number}, {name: '任务用户', data: task_users_number},
     {name: '活跃用户', data: active_users_number},
     {name: '交易用户', data: order_users_number}]
  end


  def table_data
    new_users_records = new_users.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
    task_users_records = task_users.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
    active_users_records = active_users.group_by{|record| record.last_active_at.strftime '%Y-%m-%d'}
    order_users_records = order_users.group_by{|record| record.payment_at.strftime '%Y-%m-%d'}
    date_datas = []
    date_headers.each do |date|
      new_users_data = new_users_records[date]
      task_users_data = task_users_records[date]
      active_users_data = active_users_records[date]
      order_users_data = order_users_records[date]
      datas = []

      datas << {name: '新增用户', data: new_users_data.blank? ? 0 : new_users_data.size}
      datas << {name: '任务用户', data: task_users_data.blank? ? 0 : task_users_data.uniq{|fission_log| fission_log.user_id}.size }
      datas << {name: '活跃用户', data: active_users_data.blank? ? 0 : active_users_data.size}
      datas << {name: '交易用户', data: order_users_data.blank? ? 0 : order_users_data.uniq{|order| order.user_id}.size}

      date_datas << [date, datas]
    end
    date_datas
  end






end