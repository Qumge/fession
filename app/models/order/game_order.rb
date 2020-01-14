# == Schema Information
#
# Table name: orders
#
#  id           :bigint           not null, primary key
#  amount       :integer
#  cashed       :boolean          default(FALSE)
#  desc         :text(65535)
#  express_no   :string(255)
#  express_type :string(255)
#  no           :string(255)
#  payment_at   :datetime
#  platform     :string(255)
#  receive_at   :datetime
#  send_at      :datetime
#  status       :string(255)
#  type         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  address_id   :integer
#  company_id   :integer
#  prize_log_id :integer
#  user_id      :integer
#

class Order::GameOrder < Order

end
