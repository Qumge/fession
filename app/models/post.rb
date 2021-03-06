# == Schema Information
#
# Table name: posts
#
#  id         :bigint           not null, primary key
#  content    :text(65535)
#  number     :integer          default(0)
#  status     :string(255)
#  title      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class Post < ApplicationRecord
  has_many :images, -> {where(model_type: 'Post')}, foreign_key: :model_id
  include AASM
  belongs_to :user
  has_many :audit_post_audits, :class_name => 'Audit::PostAudit', foreign_key: :model_id

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
      transitions :from => [:wait, :failed], :to => :success
    end


    #审核失败
    event :do_failed do
      transitions :from => [:wait, :success], :to => :failed
    end

  end

  def get_status
    STATUS[self.status.to_s.to_sym]
  end

  def fetch_params params
    images = []
    if params[:images].present?
      JSON.parse(params[:images]).each do |image|
        images << Image.new(file_path: image, model_type: 'Post')
      end
    end
    self.images = images
    self.update title: params[:title], content: params[:content]
    self
  end

  class << self
    def show_sort
      self.all
    end

    def search_conn params
      posts = self.all
      if params[:search].present?
        posts = posts.where('posts.title like ?', "%#{params[:search]}%")
      end
      if params[:status].present?
        posts = posts.where status: params[:status]
      end
      posts
    end

  end

end
