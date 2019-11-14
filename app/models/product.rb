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
  has_many :images, -> { where(model_type: 'Product') }, foreign_key: :model_id
  validates_presence_of :name, :stock, :images, :category_id

  before_create :set_no

  STATUS = { wait: '新商品', check: '审核中', down: '已下架', up: '已上架', failed: '审核失败'}

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


  def new_for_api params, company
    product = self.new name: params[:name], desc: params[:desc], company: company, category_id: params[:category_id]
    if params[:type] == 'CoinProduct'
      product.stock = params[:stock]
      product.price = params[:price]
    else
      product.coin = params[:coin]
      norms = []
      params[:norms].each do |norm|
        p norm, norm['price']
        norms << Norm.new(name: norm['name'], stock: norm['stock'], price: norm['price'])
      end
      product.norms = norms
    end

    images = []
    params[:images].each do |image|
      images << Image.new(file_path: image, model_type: 'Product')
    end
    product.images = images
    product
  end

  def edit_for_api params
    self.attributes = {name: params[:name], desc: params[:desc], category_id: params[:category_id]}
    if params[:type] == 'CoinProduct'
      self.stock = params[:stock]
      self.price = params[:price]
    else
      self.coin = params[:coin]
      norms = []
      params[:norms].each do |norm|
        n = self.find_by id: norm['id']
        n = self.norms.new if n.blank?
        n.attributes = {name: norm['name'], stock: norm['stock'], price: norm['price']}
        norms << n
      end
      self.norms = norms
    end

    images = []
    params[:images].each do |image|
      images << Image.new(file_path: image, model_type: 'Product')
    end
    self.images = images
    self
  end

  ### 规则 商家商品 1 + id4位(不足补0) + 时间戳; 金币商品： 20 + 时间戳
  def set_no
    if company_id.present?
      self.no = "10#{(4 - company_id.to_s.size).times.collect {|s| '0'}.join ''}#{company_id}#{Time.now.to_i}"
    else
      self.no = "20#{self.company_id}#{Time.now.to_i}"
    end

  end

  def get_status
    STATUS[self.status.to_sym]
  end


end
