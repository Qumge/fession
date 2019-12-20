class Record

  def initialize args = {}
    @type = args[:type]
    @game_type = args[:game_type]
    @date_from = args[:form]
    @date_from ||= (DateTime.now-6.days).beginning_of_day
    @date_to = args[:to]
    @date_to ||= DateTime.now.end_of_day
    @company_id = args[:company_id]
    @task_id = args[:task_id]
    @game_id = args[:game_id]
  end

  def records

  end

  def date_headers
    (@date_from..@date_to).collect {|date| date.strftime '%Y-%m-%d'}
  end

  def date_group_records
    records.group_by{|record| record.created_at.strftime '%Y-%m-%d'}
  end

  def line_data
    date_records.values
  end



  class << self

    def data params={}
      case @type
      when 'Task::GameTask'
        task_game_data params
      when 'Task::ProductTask'
        task_product_data params
      else
        task_data params
      end
    end


    def coin_per_user params={}
      share_data = Record::ShareLog.new(params).date_records
      task_coin_data = Record::TaskCoinLog.new(params).date_records
      task_coin_data.deep_merge(share_data) do |key, task_coin, share|
        if share.to_i != 0
          (task_coin.to_f / share).round 2
        else
          '-'
        end
      end
    end

    def chart_data params={}
      prize_coin_data = Record::PrizeCoinLog.new(params).line_data
      prize_data = Record::PrizeLog.new(params).line_data
      share_data = Record::ShareLog.new(params).line_data
      data = Record::ShareLog.new(params).line_data
    end


    def task_data params={}
      date_headers = self.new.date_headers

      #分享次数
      share_data = Record::ShareLog.new(params).date_records
      #查看次数
      view_data = Record::ViewLog.new(params).date_records
      # 分享消耗金币
      task_coin_data = Record::TaskCoinLog.new(params).date_records



      chart_data = [{
          name: '分享次数',
          data: share_data.values
      },
       {
           name: '查看次数',
           data: view_data.values
       },
       {
           name: '分享消耗金币',
           data: task_coin_data.values
       }
      ]
      table_data = share_data
      table_data.deep_merge!(view_data){|key, this_value, other_value| this_value.is_a?(Array) ? this_value << other_value : [this_value, other_value]}
      table_data.deep_merge!(task_coin_data){|key, this_value, other_value| this_value.is_a?(Array) ? this_value << other_value : [this_value, other_value]}


      return date_headers, chart_data, table_data
    end

    def task_game_data params={}
      date_headers, chart_data, table_data = task_data params
      # 中奖人数
      prize_data = Record::PrizeLog.new(params).date_records
      #中奖消耗金币
      prize_coin_data = Record::PrizeCoinLog.new(params).date_records
      #获客成本
      coin_per_user_data = coin_per_user params

      chart_data = chart_data.push([
          {
              name: '中奖人数',
              data: prize_data.values
          },
          {
              name: '中奖消耗金币',
              data: prize_coin_data.values
          },
          {
              name: '获客成本',
              data: coin_per_user_data.values
          }
      ]).flatten


      table_data.deep_merge!(prize_data){|key, this_value, other_value| this_value.is_a?(Array) ? this_value << other_value : [this_value, other_value]}
      table_data.deep_merge!(prize_coin_data){|key, this_value, other_value| this_value.is_a?(Array) ? this_value << other_value : [this_value, other_value]}
      table_data.deep_merge!(coin_per_user_data){|key, this_value, other_value| this_value.is_a?(Array) ? this_value << other_value : [this_value, other_value]}


      return date_headers, chart_data, table_data
    end


    def task_product_data params={}
      date_headers, chart_data, table_data = task_data params
      # 购买商品返还
      product_coin_data = Record::ProductCoinLog.new(params).date_records
      # 成交金额
      p Record::OrderProduct, 111
      product_order_data = Record::OrderProductPay.new(params).date_records
      #获客成本
      coin_per_user_data = coin_per_user params

      chart_data = chart_data.push([
                                       {
                                           name: '成交消耗金币',
                                           data: product_coin_data.values
                                       },
                                       {
                                           name: '成交金额',
                                           data: product_order_data.values
                                       },
                                       {
                                           name: '获客成本',
                                           data: coin_per_user_data.values
                                       }
                                   ]).flatten


      table_data.deep_merge!(product_coin_data){|key, this_value, other_value| this_value.is_a?(Array) ? this_value << other_value : [this_value, other_value]}
      table_data.deep_merge!(product_order_data){|key, this_value, other_value| this_value.is_a?(Array) ? this_value << other_value : [this_value, other_value]}
      table_data.deep_merge!(coin_per_user_data){|key, this_value, other_value| this_value.is_a?(Array) ? this_value << other_value : [this_value, other_value]}


      return date_headers, chart_data, table_data
    end


  end



end


