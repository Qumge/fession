# == Schema Information
#
# Table name: replies
#
#  id               :bigint           not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  questionnaire_id :integer
#  user_id          :integer
#

class Reply < ApplicationRecord
  belongs_to :user
  belongs_to :questionnaire
  has_many :answers
  after_create :set_commission

  def set_commission
    if questionnaire.task_questionnaire_task.present?
      CommissionLog.find_or_create_by task: questionnaire.task_questionnaire_task, user: user
    end
  end
end
