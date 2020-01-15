# == Schema Information
#
# Table name: share_logs
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  fission_log_id :integer
#  user_id        :integer
#

class ShareLog < ApplicationRecord
  validates_presence_of :fission_log_id
  belongs_to :fission_log
  belongs_to :user

  after_create :fission_coin

  #fission_log: 分享来源
  #user: 分享目标

  def fission_coin
    task = self.fission_log.task
    task.update share_num: task.share_num + 1 if task.present?
    fission_log = self.fission_log
    if fission_log.parent.present?
      fission_log.parent.fission_coin 1, self
    end
  end

  def task_name
    self.fission_log&.task&.view_name
  end

  def token
    self.fission_log&.token
  end

  def user_name
    self.user&.nick_name
  end

  def company_name
    self.fission_log&.task&.company&.name
  end

  def from_user_name
    self.fission_log&.user&.nick_name
  end

  def share_logs
    my_fission_log = self.fission_log.descendants.where(user: self.user, task: self.fission_log.task).first
    p my_fission_log, 111
    if my_fission_log.present?
      my_fission_log.share_logs
    end 
  end

end
