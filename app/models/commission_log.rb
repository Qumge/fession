# == Schema Information
#
# Table name: commission_logs
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  task_id    :integer
#  user_id    :integer
#

class CommissionLog < ApplicationRecord
	belongs_to :user
	belongs_to :task
	after_create :set_coin_log

	def set_coin_log
		if task.type == 'Task::ArticleTask'
			CoinLog.create model_id: self.id, coin: task.commission.to_i, channel: 'view', company: task.company, user: user
		elsif task.type == 'Task::QuestionnaireTask'
			CoinLog.create model_id: self.id, coin: task.commission.to_i, channel: 'answer', company: task.company, user: user
		end
	end
end
