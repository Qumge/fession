class Record::PrizeCoinLog < Record

  def records_scope
    ::CoinLog.joins(prize_log: {game: :task_game_task})
  end

  def search_conn
    conn = ["channel = 'prize'"]
    if @date_from.present?
      conn << "coin_logs.created_at >= '#{@date_from}'"
    end
    if @date_to.present?
      conn << "coin_logs.created_at < '#{@date_to}'"
    end
    if @company_id.present?
      conn << "games.company_id = #{@company_id}"
    end
    if @task_id.present?
      conn << "tasks.id = #{@task_id}"
    end
    if @game_type.present?
      conn << "games.type = '#{@game_type}'"
    end
    if @game_id.present?
      conn << "games.id = #{@game_id}"
    end
    conn.join ' and '
  end

  def records
    records_scope.where search_conn
  end

  def date_records
    s = {}
    date_headers.each do |date|
      data = date_group_records[date]
      s[date] = data.present? ? data.sum(:coin) : 0
    end
    s
  end


end