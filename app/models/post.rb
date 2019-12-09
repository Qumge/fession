class Post < ApplicationRecord
  include AASM
  belongs_to :user

  STATUS = { wait: '待审核', failed: '已拒绝', success: '已发布'}

  aasm :status do
    state :wait, :initial => true
    state :failed, :success

    # # 申请审核
    # event :do_wait do
    #   transitions :from => :new, :to => :wait
    # end

    # 审核成功
    event :do_success do
      transitions :from => :wait, :to => :success
    end


    #审核失败
    event :do_failed do
      transitions :from => :wait, :to => :failed
    end

  end

  def get_status
    STATUS[self.status.to_s.to_sym]
  end

  def fetch_params params
    self.update title: params[:title], content: params[:content]
    self
  end

  class << self
    def show_sort
      self.all
    end

  end

end
