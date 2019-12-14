# == Schema Information
#
# Table name: tasks
#
#  id           :bigint           not null, primary key
#  coin         :bigint
#  deleted_at   :datetime
#  name         :string(255)
#  residue_coin :bigint
#  status       :string(255)
#  type         :string(255)
#  valid_from   :datetime
#  valid_to     :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  company_id   :integer
#  model_id     :integer
#
# Indexes
#
#  index_tasks_on_deleted_at  (deleted_at)
#

class Task::QuestionnaireTask < Task
  belongs_to :questionnaire, foreign_key: :model_id, class_name: "::Questionnaire"
  def view_name
    self.questionnaire&.name
  end

  def h5_link
    "#{Settings.h5_url}/pages/task/questionnaire?id=#{self.id}"
  end

end
