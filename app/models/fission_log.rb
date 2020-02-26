# == Schema Information
#
# Table name: fission_logs
#
#  id         :bigint           not null, primary key
#  ancestry   :string(255)
#  token      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  task_id    :integer
#  user_id    :integer
#

class FissionLog < ApplicationRecord
  has_ancestry

  belongs_to :user
  belongs_to :task
  has_many :share_logs
  after_create_commit :set_task_num
  has_many :view_logs

  validates_presence_of :task_id
  validates_presence_of :user_id


  has_many :audits, foreign_key: :model_id


  class << self
    def assign_coin

    end
  end

  def fission_coin level, share_log
    p self, 1111
    rule = ShareRule.find_by level: level
    p 3333, rule, task.company
    p task.time_valid?, task.success?, task.residue_coin.to_i > rule.coin, task.company.coin.to_i > rule.coin
    if task.time_valid? && task.success? && task.residue_coin.to_i > rule.coin && task.company.coin.to_i > rule.coin
      CoinLog.create company: task.company, channel: 'fission', coin: rule.coin, share_log: share_log, user: user, model_id: self.id
      self.parent.fission_coin(level+1, share_log) if self.parent.present?
    end
  end

  def share_num
    self.share_logs.size
  end

  def view_num
    self.view_logs.size
  end


  def set_task_num
    self.task.update number: self.task.number + 1
  end

  def sort_share_logs
    self.share_logs.order('created_at desc')
  end

end
