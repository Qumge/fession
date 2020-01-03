# == Schema Information
#
# Table name: order_payments
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  order_id   :integer
#  payment_id :integer
#

class OrderPayment < ApplicationRecord
end
