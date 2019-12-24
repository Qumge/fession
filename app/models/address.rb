class Address < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :content
  validates_presence_of :phone
  belongs_to :company
  belongs_to :user
  before_save :set_default
  validates_format_of :phone, with: /\A1[3|4|5|7|8][0-9]{9}\z/, if: proc{|address| address.phone.present?}
  TAGS = {send: '发货地址', receive: '收货地址', all: '收货+发货'}
  class << self
    def operator_address
      self.where(user_id: nil, company_id: nil)
    end
  end

  def send?
    ['all', 'send'].include? self.tag
  end

  def receive?
    ['all', 'receive'].include? self.tag
  end

  def set_tag addresses, type
    case type
    when 'send'
      address = addresses.where(tag: type)
      address.update tag: nil if address.present?
      address = addresses.where(tag: 'all')
      address.update tag: 'receive' if address.present?
      if self.tag == 'receive'
        self.update tag: 'all'
      else
        self.update tag: type
      end
    when 'receive'
      address = addresses.where(tag: type)
      address.update tag: nil if address.present?
      address = addresses.where(tag: 'all')
      address.update tag: 'send' if address.present?
      if self.tag == 'send'
        self.update tag: 'all'
      else
        self.update tag: type
      end
    end
  end

  def set_default
    if self.user.present?
      default_address =  self.user.addresses.where('addresses.tag != ? and addresses.id != ?', 'default', self.id)
      if default_address.present?
        if self.tag == 'default'
          self.user.addresses.where('addresses.id != ?', self.id).update_all tag: null
        end
      else
        self.tag = 'default'
      end
    end
  end
end
