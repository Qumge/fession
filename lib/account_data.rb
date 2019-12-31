class AccountData
  def initialize args = {}
    @date_from = args[:date_from]
    @date_from ||= (DateTime.now-6.days).beginning_of_day
    @date_to = args[:date_to]
    @date_to ||= DateTime.now.end_of_day
    @user_id = args[:user_id]
  end

  def date_headers
    (@date_from..@date_to).collect {|date| date.strftime '%Y-%m-%d'}
  end


  # 金币数
  def coin_logs
    coins = CoinLog.where(created_at: @date_from..@date_to)
    coins = coins.where(user_id: @user_id) if @user_id.present?
  end

  # 分享数
  def share_logs
    shares = ShareLog.where(created_at: @date_from..@date_to)
    shares = shares.where(user_id: @user_id) if @user_id.present?
  end

  # 查看次数
  def view_logs
    views = UserViewLog.where(created_at: @date_from..@date_to)
    views = views.where(user_id: @user_id) if @user_id.present?
  end



  def total_data
    [{name: '金币数', data: coin_logs.sum(:coin)}, {name: '分项数', data: share_logs.count}, {name: '查看次数', data: view_logs.count}]
  end


  def data
    return total_data, date_headers, chart_data, table_data
  end


  def chart_data
    coin_date_data = coin_logs.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
    share_date_data = share_logs.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
    view_date_data = view_logs.group_by{|record| record.created_at.strftime '%Y-%m-%d'}


    coin_number = []
    share_number = []
    view_number = []
    date_headers.each do |date|
      # 金币数
      coin_number << (coin_date_data[date].present? ? coin_date_data[date].sum{|coin_log| coin_log.coin } : 0)
      # 分项数
      share_number << (share_date_data[date].present? ? share_date_data[date].size : 0)
      # 查看数
      view_number << (view_date_data[date].present? ? view_date_data[date].size : 0)
    end

    [{name: '金币数', data: coin_number}, {name: '分享数', data: share_number}, {name: '查看数', data: view_number}]
  end


  def table_data
    coin_date_data = coin_logs.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
    share_date_data = share_logs.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
    view_date_data = view_logs.group_by{|record| record.created_at.strftime '%Y-%m-%d'}

    date_datas = []
    date_headers.each do |date|
      coin_data = coin_date_data[date]
      share_data = share_date_data[date]
      view_data = view_date_data[date]
      datas = []

      datas << {name: '金币数', data: coin_data.blank? ? 0 : coin_data.sum{|coin_log| coin_log.coin }.size}
      datas << {name: '分享数', data: share_data.blank? ? 0 : share_data.size }
      datas << {name: '查看数', data: view_data.blank? ? 0 : view_data.size}

      date_datas << [date, datas]
    end
    date_datas
  end


end