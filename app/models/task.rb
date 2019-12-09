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

class Task < ApplicationRecord
  include AASM
  belongs_to :company
  belongs_to :game, foreign_key: :model_id
  validates_presence_of :company_id
  has_many :audit_task_audits, :class_name => 'Audit::TaskAudit', foreign_key: :model_id
  has_many :fission_logs

  STATUS = { wait: '待审核', failed: '已拒绝', success: '审核成功', active: '进行中', overtime: '已结束'}

  aasm :status do
    state :wait, :initial => true
    state :failed, :success, :overtime

    # # 申请审核
    # event :do_wait do
    #   transitions :from => :new, :to => :wait
    # end

    # 审核成功
    event :do_success do
      transitions :from => :wait, :to => :success, after: Proc.new {set_residue}
    end

    # 已结束
    event :do_overtime do
      transitions :from => :success, :to => :overtime, after: Proc.new {set_residue}
    end

    #审核失败
    event :do_failed do
      transitions :from => :wait, :to => :failed
    end

    #重新审核
    event :do_wait do
      transitions :from => [:failed], :to => :wait
    end
  end
  class << self
    def search_conn params
      tasks = self.order('valid_from desc')
      if params[:status].present?
        case params[:status]
        when 'active'
          tasks = tasks.where(status: 'success').where('valid_to > ?', DateTime.now)
        when 'overtime'
          #tasks = tasks.where(status: 'success').where('valid_to < ?', DateTime.now)
          tasks = tasks.where("(tasks.status = ? and tasks.valid_to < ？) or tasks.status = ?", 'success', DateTime.now, 'overtime')
        else
          tasks = tasks.where(status: params[:status])
        end
      end
      tasks
    end

    def search_game_conn params
      tasks = self.all.order('valid_from desc')
      if params[:status].present?
        case params[:status]
        when 'active'
          tasks = tasks.where(status: 'success').where('valid_to > ?', DateTime.now)
        when 'overtime'
          tasks = tasks.where("(tasks.status = ? and tasks.valid_to < ？) or tasks.status = ?", 'success', DateTime.now, 'overtime')
        else
          tasks = tasks.where(status: params[:status])
        end
      end

      if params[:type].present?
        tasks = tasks.where('games.type = ?', params[:type])
      end
      tasks
    end
  end

  def failed_reason
    if self.failed?
      self.audit_task_audits.where(to_status: 'failed').last&.reason
    end
  end

  def get_status
    case self.status
    when 'success'
      #tasks = tasks.where(status: 'success').where('valid_to < ?', DateTime.now)
      self.valid_to >= DateTime.now ? '进行中' : '已结束'
    else
      STATUS[self.status.to_sym] if self.status.present?
    end
  end

  def time_valid?
    DateTime.now >= self.valid_from && DateTime.now <= self.valid_to
  end

  def set_residue
    self.update residue_coin: self.coin
  end

  def h5_link
    "http://fission.natapp1.cc/pages/task/show?id=#{self.id}"
  end

end
