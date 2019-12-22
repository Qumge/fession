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
  has_one :image, -> {where(model_type: 'Task')}, foreign_key: :model_id
  has_many :view_logs
  belongs_to :product, foreign_key: :model_id
  belongs_to :article, foreign_key: :model_id
  belongs_to :questionnaire, foreign_key: :model_id
  belongs_to :game, foreign_key: :model_id

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
      tasks = self.all
      if params[:sorts].present?
        sorts = JSON.parse params[:sorts]
        s = sorts.collect{|sort| "#{sort['column']} #{sort['sort']}"}.join ','
        tasks = tasks.order(s)
      end
      tasks = tasks.order('valid_from desc')
      if params[:status].present?
        case params[:status]
        when 'active'
          tasks = tasks.where(status: 'success').where('valid_to > ?', DateTime.now)
        when 'overtime'
          #tasks = tasks.where(status: 'success').where('valid_to < ?', DateTime.now)
          tasks = tasks.where("(tasks.status = ? and tasks.valid_to < ?) or tasks.status = ?", 'success', DateTime.now, 'overtime')
        else
          tasks = tasks.where(status: params[:status])
        end
      end
      tasks
    end

    def search_game_conn params
      tasks = self.all
      if params[:sorts].present?
        sorts = JSON.parse params[:sorts]
        s = sorts.collect{|sort| "#{sort['column']} #{sort['sort']}"}.join ','
        tasks = tasks.order(s)
      end
      tasks = tasks.order('valid_from desc')
      if params[:status].present?
        case params[:status]
        when 'active'
          tasks = tasks.where(status: 'success').where('valid_to > ?', DateTime.now)
        when 'overtime'
          tasks = tasks.where("(tasks.status = ? and tasks.valid_to < ?) or tasks.status = ?", 'success', DateTime.now, 'overtime')
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

  # 分享消耗金币
  def cost_coin
    self.coin.to_i - self.residue_coin.to_i
  end

  # 获客成本
  def user_per_coin
    if view_num.present? && view_num > 0
      (cost_coin.to_f / view_num).round 2
    else
      '-'
    end

  end

  # 分享数据
  def share_data from=nil, to=nil
    share_logs = ShareLog.joins(fission_log: :task).where('tasks.id = ?', self.id)
    if from.present?
      share_logs = share_logs.where('share_logs.created_at >= ?', from)
    end
    if to.present?
      share_logs = share_logs.where('share_logs.created_at < ?', to)
    end
    share_logs
  end

  # 浏览数据
  def view_data from=nil, to=nil
    view_logs = self.view_logs
    if from.present?
      view_logs = view_logs.where('view_logs.created_at >= ?', from)
    end
    if to.present?
      view_logs = view_logs.where('view_logs.created_at < ?', to)
    end
    view_logs
  end

  # 金币消耗数据
  def coin_data from=nil, to=nil
    coin_logs = CoinLog.joins(share_log: {fission_log: :task}).where('tasks.id = ?', self.id)
    if from.present?
      coin_logs = coin_logs.where('coin_logs.created_at >= ?', from)
    end
    if to.present?
      coin_logs = coin_logs.where('coin_logs.created_at < ?', to)
    end
    coin_logs
  end

end
