# == Schema Information
#
# Table name: company_cashes
#
#  id            :bigint           not null, primary key
#  amount        :integer
#  bank_code     :string(255)
#  enc_bank_no   :string(255)
#  enc_true_name :string(255)
#  no            :string(255)
#  response_data :text(65535)
#  status        :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  company_id    :integer
#

class CompanyCash < ApplicationRecord
	include AASM
	belongs_to :company
	STATUS = {wait: '待打款', paying: '打款中', failed: '打款失败', success: '打款成功' }
  BANK = {"1002"=>"工商银行", "1005"=>"农业银行", "1003"=>"建设银行", "1026"=>"中国银行", "1020"=>"交通银行", "1001"=>"招商银行", "1066"=>"邮储银行", "1006"=>"民生银行", "1010"=>"平安银行", "1021"=>"中信银行", "1004"=>"浦发银行", "1009"=>"兴业银行", "1022"=>"光大银行", "1027"=>"广发银行", "1025"=>"华夏银行", "1056"=>"宁波银行", "4836"=>"北京银行", "1024"=>"上海银行", "1054"=>"南京银行"}
	after_create :pay_bank

  aasm :status do
    state :wait, :initial => true
    state :failed, :success, :paying

    # # 申请审核
    # event :do_wait do
    #   transitions :from => :new, :to => :wait
    # end

    #
    event :do_paying do
      transitions :from => :wait, :to => :paying
    end
    event :do_success do
      transitions :from => :paying, :to => :success, after: Proc.new{set_amount}
    end

    event :do_failed do
      transitions :from => :paying, :to => :failed
    end
  end


  def pay_bank
    if self.may_do_paying?
    	#TODO
	    self.do_paying!
    	params = {
        enc_bank_no: self.enc_bank_no,
        enc_true_name: self.enc_true_name,
        bank_code: self.bank_code,
        amount: self.amount,
        desc: '金币提现',
        partner_trade_no: self.no
	    }
	    r = WxPay::Service.pay_bank params
	    if r[:raw]
	      self.update response_data: r[:raw]['xml']
	      if r[:result_code] && raw[:result_code] == 'SUCCESS'
	        self.do_success! if self.may_do_success?
	      else
	        self.do_failed! if self.may_do_failed?
	      end
	    end
    end
    
  end

  
  def get_status
    STATUS[self.status.to_sym] if self.status.present?
  end

  def bank
    BANK[self.bank_code] if self.bank_code.present?
  end

  def set_amount
  	self.company.update withdraw_amount: self.company.withdraw_amount.to_i + self.amount 
  end


end
