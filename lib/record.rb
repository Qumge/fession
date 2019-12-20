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

  class << self
    def chart_data params
      prize_coin_data = Record::PrizeCoinLog.new(params).date_group_records
      prize_data = Record::PrizeLog.new(params).date_group_records
      share_data = Record::ShareLog.new(params).date_group_records
      data = Record::ShareLog.new(params).date_group_records
    end
  end

end