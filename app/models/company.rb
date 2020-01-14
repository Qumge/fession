# == Schema Information
#
# Table name: companies
#
#  id              :bigint           not null, primary key
#  active_amount   :bigint           default(0)
#  active_at       :datetime
#  bank_code       :string(255)
#  cashes          :integer          default(0)
#  coin            :bigint           default(0)
#  deleted_at      :datetime
#  enc_bank_no     :string(255)
#  enc_true_name   :string(255)
#  invalid_amount  :bigint           default(0)
#  locked_at       :datetime
#  name            :string(255)
#  no              :string(255)
#  return_amount   :bigint           default(0)
#  status          :string(255)
#  total_amount    :bigint           default(0)
#  withdraw_amount :bigint           default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_companies_on_deleted_at  (deleted_at)
#

class Company < ApplicationRecord
  include AASM
  validates_uniqueness_of :name
  validates_presence_of :name
  has_many :articles
  has_and_belongs_to_many :followers , join_table: 'company_follows', foreign_key: :follow_id, class_name: "User"
  has_many :banner_company_banners, :class_name => 'Banner::CompanyBanner'
  has_many :addresses
  has_one :image, -> {where(model_type: 'Company')}, foreign_key: :model_id
  has_many :company_payments
  has_many :company_cashes
  acts_as_paranoid

  before_create :set_no
  has_many :customers
  has_one :customer, -> {where(role_type: 'admin_customer')}
  has_many :money_products

  STATUS = {active: '正常', locked: '冻结'}

  include AASM
  aasm :status do
    state :active, :initial => true
    state :locked

    #冻结
    event :do_lock do
      transitions :from => :active, :to => :locked
    end

    #解冻
    event :do_active do
      transitions :from => :locked, :to => :active
    end
  end

  class << self
    def search_conn params
      companies = self.all
      if params[:status].present?
        companies = companies.where(status: params[:status])
      end
      if params[:search].present?
        companies = companies.where('companies.no like ? or companies.name like ?', "%#{params[:search]}%", "%#{params[:search]}%")
      end
      companies
    end
  end

  def receive_address
    self.addresses.where(tag: ['receive', 'all']).first
  end

  def can_cash? amount
    self.active_amount >= 100 * amount && self.enc_bank_no.present? && self.enc_true_name.present? && self.bank_code.present?
  end

  def do_cash amount
    self.company_cashes.create enc_true_name: self.enc_true_name, bank_code: self.bank_code, enc_bank_no: self.enc_bank_no, amount: 100*amount, no: "C#{DateTime.now.to_i}"
  end

  def senf_address
    self.addresses.where(tag: ['senf', 'all']).first
  end

  def get_status
    STATUS[self.status.to_sym] if self.status.present?
  end

  def set_no
    self.no = "#{Time.now.to_i}#{rand(1000..9999).to_s}"
  end



end
