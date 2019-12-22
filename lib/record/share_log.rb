class Record::ShareLog < Record

  def records_scope
    case @type
    when 'Task::GameTask'
      ::ShareLog.joins(fission_log: {task: :game}).where('tasks.type = ?', 'Task:GameTask')
    when 'Task::ArticleTask'
      ::ShareLog.joins(fission_log: {task: :article}).where('tasks.type = ?', 'Task:ArticleTask')
    when 'Task:LinkTask'
      ::ShareLog.joins(fission_log: :task).where.('tasks.type = ?', 'Task:LinkTask')
    when 'Task::ProductTask'
      ::ShareLog.joins(fission_log: {task: :product}).where('tasks.type = ?', 'Task::ProductTask')
    when 'Task::QuestionnaireTask'
      ::ShareLog.joins(fission_log: {task: :questionnaire}).where('tasks.type = ?', 'Task::QuestionnaireTask')
    else
      ::ShareLog.joins(fission_log: :task)
    end
  end

  def search_conn
    conn = []
    if @date_from.present?
      conn << "share_logs.created_at >= '#{@date_from}'"
    end
    if @date_to.present?
      conn << "share_logs.created_at < '#{@date_to}'"
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
      s[date] = data.present? ? data.size : 0
    end
    s
  end


end