# == Schema Information
#
# Table name: tasks
#
#  id           :bigint           not null, primary key
#  amount       :integer          default(0)
#  coin         :bigint
#  deleted_at   :datetime
#  name         :string(255)
#  number       :integer          default(0)
#  residue_coin :bigint
#  sale         :integer          default(0)
#  sale_coin    :integer          default(0)
#  share_link   :string(255)
#  share_num    :integer          default(0)
#  status       :string(255)
#  type         :string(255)
#  valid_from   :datetime
#  valid_to     :datetime
#  view_num     :integer          default(0)
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

  def h5_path
    "/pages/task/questionnaire?id=#{self.id}"
  end

end
