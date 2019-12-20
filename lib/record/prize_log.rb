class Record::PrizeLog < Record

  def records_scope
    ::PrizeLog.joins(prize: {game: :task_game_task})
  end

  def search_conn
    conn = []
    if @form.present?
      conn << "prize_logs.created_at >= '#{@date_from}'"
    end
    if @date_to.present?
      conn << "prize_logs.created_at < '#{@date_to}'"
    end
    if @company_id.present?
      conn << "games.company_id = '#{@company_id}'"
    end
    if @task_id.present?
      conn << "tasks.id = '#{@task_id}'"
    end
    if @game_type.present?
      conn << "games.type = '#{@game_type}'"
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
      s[date] = data.present? ? data.size : 0
    end
    s
  end


end