class Record::ViewLog < Record

  def records_scope
    case @type
    when 'Task::GameTask'
      ::ViewLog.joins(task: :game)
    when 'Task::ArticleTask'
      ::ViewLog.joins(task: :article)
    when 'Task:LinkTask'
      ::ViewLog.joins(task: :article)
    when 'Task::ProductTask'
      ::ViewLog.joins(task: :product)
    when 'Task::QuestionnaireTask'
      ::ViewLog.joins(task: :questionnaire)
    else
      ::ViewLog.joins(:task)
    end
  end

  def search_conn
    conn = []
    if @date_from.present?
      conn << "view_logs.created_at >= '#{@date_from}'"
    end
    if @date_to.present?
      conn << "view_logs.created_at < '#{@date_to}'"
    end
    if @company_id.present?
      conn << "tasks.company_id = '#{@company_id}'"
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