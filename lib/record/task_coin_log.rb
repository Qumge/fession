class Record::TaskCoinLog < Record

  def records_scope
    case @type
    when 'Task::GameTask'
      ::CoinLog.joins(share_log: {fission_log: {task: :game}})
    when 'Task::ArticleTask'
      ::CoinLog.joins(share_log: {fission_log: {task: :article}})
    when 'Task:LinkTask'
      ::CoinLog.joins(share_log: {fission_log: :task})
    when 'Task::ProductTask'
      ::CoinLog.joins(share_log: {fission_log: {task: :product}})
    when 'Task::QuestionnaireTask'
      ::CoinLog.joins(share_log: {fission_log: {task: :questionnaire}})
    else
      ::CoinLog.joins(share_log: {fission_log: :task})
    end
  end

  def search_conn
    conn = ["coin_logs.channel = 'fission'"]
    if @date_from.present?
      conn << "coin_logs.created_at >= '#{@date_from}'"
    end
    if @date_to.present?
      conn << "coin_logs.created_at < '#{@date_to}'"
    end
    if @company_id.present?
      conn << "tasks.company_id = #{@company_id}"
    end
    if @task_id.present?
      conn << "tasks.id = #{@task_id}"
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
      s[date] = data.present? ? data.sum{|d| d.coin.to_i} : 0
    end
    s
  end


end