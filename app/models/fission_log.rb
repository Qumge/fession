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

  validates_presence_of :task_id
  validates_presence_of :user_id


  has_many :audits, foreign_key: :model_id


  class << self
    def assign_coin

    end
  end

  def fission_coin level, share_log
    rule = ShareRule.find_by level: level
    p 3333, rule, task.company
    p task.time_valid?, task.success?, task.residue_coin.to_i > rule.coin, task.company.coin.to_i > rule.coin
    if task.time_valid? && task.success? && task.residue_coin.to_i > rule.coin && task.company.coin.to_i > rule.coin
      user.coin_logs.create company: task.company, channel: 'fission', coin: rule.coin, model_id: self.id, share_log: share_log
      self.parent.fission_coin(level+1, share_log) if self.parent.present?
    end
  end

  def set_task_num
    self.task.update number: self.task.number + 1
  end

end
