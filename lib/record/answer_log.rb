class Record::AnswerLog < Record

  def records_scope
    ::Answer.joins(questionnaire: :task_questionnaire_task).group('answers.questionnaire_id, answers.user_id')
  end

  def search_conn
    conn = []
    if @date_from.present?
      conn << "answers.created_at >= '#{@date_from}'"
    end
    if @date_to.present?
      conn << "answers.created_at < '#{@date_to}'"
    end
    if @company_id.present?
      conn << "questionnaires.company_id = #{@company_id}"
    end
    if @task_id.present?
      conn << "tasks.id = #{@task_id}"
    end
    conn.join ' and '
  end

  def records
    records_scope.where(search_conn).select('count(*), MAX(answers.created_at) as created_at')
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