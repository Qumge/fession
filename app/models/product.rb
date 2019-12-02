# == Schema Information
#
# Table name: products
#
#  id          :bigint           not null, primary key
#  coin        :integer
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

class Product < ApplicationRecord
  include AASM
  belongs_to :company
  has_many :norms
  belongs_to :category
  has_many :images, -> {where(model_type: 'Product')}, foreign_key: :model_id
  validates_presence_of :name, :stock, :images, :category_id
  has_many :specs
  validates_uniqueness_of :name, scope: :company_id
  validates_presence_of :specs

  acts_as_paranoid


  before_create :set_no

  STATUS = {wait: '新商品', check: '审核中', down: '已下架', up: '已上架', failed: '审核失败'}

  aasm :status do
    state :wait, :initial => true
    state :check, :down, :up, :failed

    #上架 、 审核成功
    event :do_up do
      transitions :from => [:wait, :check], :to => :up
    end

    #下架
    event :do_down do
      transitions :from => :up, :to => :down
    end

    #审核失败
    event :do_failed do
      transitions :from => :check, :to => :failed
    end

    #重新编辑
    event :do_wait do
      transitions :from => :failed, :to => :wait
    end
  end

  class << self
    def search_conn params
      products = self.all
      if params[:search].present?
        products = products.where('name like ?', "%#{params[:search]}%")
      end
      if params[:company_id].present?
        products = products.where(company_id: params[:company_id])
      end
      products
    end
  end

  def spec_values
    SpecValue.joins(:spec).where('specs.product_id = ?', self.id)
  end


  def fetch_for_api params, company = nil
    self.attributes = {name: params[:name], desc: params[:desc], category_id: params[:category_id]}
    self.company = company if company.present?
    if params[:images].present?
      images = []
      JSON.parse(params[:images]).each do |image|
        images << Image.new(file_path: image, model_type: 'Product')
      end
      self.images = images
    end
    Product.transaction do
      if params[:type] == 'CoinProduct'
        self.stock = params[:stock]
        self.price = params[:price]
      else
        self.coin = params[:coin]
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
          self.save
        end
      end
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

  def get_status
    STATUS[self.status.to_sym]
  end


end
