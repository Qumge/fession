# == Schema Information
#
# Table name: after_orders
#
#  id           :bigint           not null, primary key
#  express_no   :string(255)
#  express_type :string(255)
#  status       :string(255)
#  type         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  order_id     :integer
#  user_id      :integer
#

class AfterOrder::All < AfterOrder

end
