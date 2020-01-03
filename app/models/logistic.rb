# == Schema Information
#
# Table name: logistics
#
#  id              :bigint           not null, primary key
#  name            :string(255)
#  no              :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  order_id        :integer
#  return_order_id :integer
#

class Logistic < ApplicationRecord
  belongs_to :order
  validates_presence_of :no
  validates_presence_of :name
  NAME = {yuantong: '圆通快递', zhongtong: '中通快递', shunfeng: '顺丰'}

  def get_name
    Logistic::NAME[self.name.to_sym] if self.name.present?
  end

end
