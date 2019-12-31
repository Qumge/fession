# == Schema Information
#
# Table name: products
#
#  id          :bigint           not null, primary key
#  coin        :integer
#  deleted_at  :datetime
#  desc        :text(65535)
#  name        :string(255)
#  no          :string(255)
#  price       :integer
#  sale        :integer          default(0)
#  status      :string(255)
#  stock       :integer          default(0)
#  type        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :integer
#  company_id  :integer
#
# Indexes
#
#  index_products_on_deleted_at  (deleted_at)
#

class Product < ApplicationRecord
  include AASM
  belongs_to :company
  has_many :norms
  belongs_to :category
  has_many :images, -> {where(model_type: 'Product')}, foreign_key: :model_id
  validates_presence_of :name, :stock, :images, :category_id
  validates_uniqueness_of :name, scope: :company_id
  has_many :specs
  has_many :audits, foreign_key: :model_id
  has_many :audit_product_audits, :class_name => 'Audit::ProductAudit', foreign_key: :model_id
  has_one :task_product_task, :class_name => 'Task::ProductTask', foreign_key: :model_id
  validates_presence_of :price


  acts_as_paranoid


  before_create :set_no

  STATUS = { wait: '审核中', success: '审核成功', down: '已下架', up: '已上架', failed: '审核失败'}

  aasm :status do
    state :wait, :initial => true
    state :down, :up, :failed, :success

    #审核成功 直接上架
    event :do_success do
      transitions :from => [:wait], :to => :up
    end

    #审核失败
    event :do_failed do
      transitions :from => :wait, :to => :failed
    end

    #上架
    event :do_up do
      transitions :from => [:success, :down], :to => :up
    end

    #下架
    event :do_down do
      transitions :from => :up, :to => :down
    end

    #重新编辑
    event :do_wait do
      transitions :from => [:failed], :to => :wait
    end
  end

  class << self
    def search_conn params
      products = self.all
      p params, 111
      if params[:sort].present?
        # sorts = JSON.parse params[:sort]
        # s = sorts.collect{|sort| "#{sort['column']} #{sort['sort']}"}.join ','
        products = products.order(params[:sort])
      end
      if params[:category_id].present?
        category = Category.find_by id: params[:category_id]
        if category.present?
          products = products.where(category_id: category.subtree_ids)
        end
      end
      if params[:sort].present?
        products = products.order(params[:sort])
      end
      products = products.order('created_at desc')
      if params[:search].present?
        products = products.where('products.name like ?', "%#{params[:search]}%")
      end
      if params[:status].present?
        products = products.where(status: params[:status])
      end
      if params[:company_id].present?
        products = products.where(company_id: params[:company_id])
      end
      products
    end
  end

  def failed_reason
    if self.failed?
      self.audit_product_audits.where(to_status: 'failed').last&.reason
    end
  end

  def spec_values
    SpecValue.joins(:spec).where('specs.product_id = ?', self.id)
  end


  def fetch_for_api params, company = nil
    self.name = params[:name] if params[:name].present?
    self.desc = params[:desc] if params[:desc].present?
    self.status = params[:status] if params[:status].present?
    self.category_id = params[:category_id] if params[:category_id].present?
    self.company = company if company.present?
    if params[:images].present?
      images = []
      p params[:images], 1111
      JSON.parse(params[:images]).each do |image|
        images << Image.new(file_path: image, model_type: 'Product')
      end
      self.images = images
    end
    Product.transaction do
      if params[:type] == 'CoinProduct'
        self.stock = params[:stock] if params[:stock].present?
        self.price = params[:price] if params[:price].present?
      else
        self.coin = params[:coin] if params[:coin].present?
        if params[:specs].present? && params[:norms].present?
          params_specs = JSON.parse(params[:specs])
          params_norms = JSON.parse(params[:norms])
          params_specs.each do |params_spec|
            spec = self.specs.find_or_initialize_by(name: params_spec['name'])
            params_spec['values'].each do |value|
              spec_value = spec.spec_values.find_or_initialize_by(name: value)
              spec.spec_values << spec_value
            end
            self.specs << spec
          end
          if self.save
            arr_norms = []
            params_norms.each do |params_norm|
              ids = []
              p params_norm['name'], 1111111
              spec_values = []
              params_norm['name'].each do |spec_value_name|
                spec_value = self.spec_values.find_by(name: spec_value_name)
                spec_values << spec_value
              end
              p spec_values, 22222
              spec_values.sort_by!{|spec_value| spec_value.spec_id}
              p spec_values, 11111
              spec_attrs = spec_values.map(&:id).join('/')
              p spec_attrs
              norm = self.norms.find_or_initialize_by spec_attrs: spec_attrs
              norm.price = params_norm['price'].to_i * 100
              norm.stock = params_norm['stock']
              arr_norms << norm
            end
            self.norms = arr_norms
          end
        end
      end
      self.save
      self.do_wait! if self.may_do_wait?
    end
    self
  end

  ### 规则 商家商品 1 + id4位(不足补0) + 时间戳; 金币商品： 20 + 时间戳
  def set_no
    if company_id.present?
      self.no = "10#{(4 - company_id.to_s.size).times.collect {|s| '0'}.join ''}#{company_id}#{Time.now.to_i}#{rand(1000..9999).to_s}"
    else
      self.no = "20#{Time.now.to_i}#{rand(1000..9999).to_s}"
    end
  end

  def view_price
    self.type == 'CoinProduct' ? self.price : (self.price.to_f / 100)
  end

  def h5_link
    "#{Settings.h5_url}/pages/product/show?id=#{self.id}"
  end

  def get_status
    STATUS[self.status.to_sym]
  end

  def default_image
    self.images&.first&.image_path
  end

  def set_view
    self.update view_num: self.view_num + 1
    if self.task_product_task.present? && self.task_product_task.time_valid?
      self.task_product_task.update view_num: self.task_product_task.view_num + 1
    end
  end

  def set_sale number, amount
    self.update sale: self.sale + number, amount: self.amount + amount, sale_coin: self.sale_coin + number * self.coin.to_i
    if self.task_product_task.present? && self.task_product_task.time_valid?
      self.task_product_task.update  sale: self.task_product_task.sale + number, amount: self.task_product_task.amount + amount, sale_coin: self.task_product_task.sale_coin + number * self.coin.to_i
    end
  end


end
