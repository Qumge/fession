# == Schema Information
#
# Table name: view_logs
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  fission_log_id :integer
#  task_id        :integer
#  user_id        :integer
#

class ViewLog < ApplicationRecord
  belongs_to :fission_log
  belongs_to :user
  belongs_to :task

  after_create_commit :set_num

  class << self
    def fetch_params params, user
      p params, 111
      log = self.new user: user
      if [:task_id].present?
        task = Task.find_by id: params[:task_id]
        log.task = task
        if params[:token].present?
          fission_log = FissionLog.find_by token: params[:token]
          log.fission_log = fission_log
          raise '错误的token' if fission_log.blank? || fission_log.task != task
        end
        log.save
        log
      end

    end
  end

  def set_num
    p 11111
    self.task.update view_num: self.task.view_num + 1
    if self.fission_log
      p 2222
      p user, self.fission_log.user
      # 查看人是自己
      return if self.user == self.fission_log.user
      # 查看人是自己的上级
      return if self.fission_log.ancestors.where('fission_logs.user_id = ?', self.user.id).present?
      #检查是否为第一次查看
      first_view_log = ViewLog.find_by user: self.user, fission_log: self.fission_log, task: self.task
      # 检查查看人不是你的上级
      fission_log.ancestors
      p first_view_log, 111
      if first_view_log == self 
        p 333
        share_log = ShareLog.create fission_log: self.fission_log, user: user
      end
    end
  end

end
