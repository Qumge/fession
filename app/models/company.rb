# == Schema Information
#
# Table name: companies
#
#  id              :bigint           not null, primary key
#  active_amount   :bigint           default(0)
#  active_at       :datetime
#  coin            :bigint           default(0)
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

class Company < ApplicationRecord
  include AASM
  validates_uniqueness_of :name
  validates_presence_of :name
  has_many :articles

  before_create :set_no
  has_many :customers
  has_one :customer, -> {where(role_type: 'admin_customer')}
  has_many :money_products

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

  def set_no
    self.no = "#{Time.now.to_i}#{rand(1000..9999).to_s}"
  end


end
