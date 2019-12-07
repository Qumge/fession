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

  def fission_coin
    fission_log = self.fission_log
    p 11111
    if fission_log.parent.present?
      p 22222
      fission_log.parent.fission_coin 1
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

end
