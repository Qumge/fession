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


  before_create :set_no

  def set_no

  end

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
      transitions :from => :wait, :to => :done
    end
  end
end
