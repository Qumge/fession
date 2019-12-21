class Logistic < ApplicationRecord
  belongs_to :order
  validates_presence_of :no
  validates_presence_of :name
  NAME = {yuantong: '圆通快递', zhongtong: '中通快递', shunfeng: '顺丰'}

  def get_name
    Logistic::NAME[self.name.to_sym] if self.name.present?
  end

end
