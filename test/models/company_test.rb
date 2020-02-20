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
#  live            :boolean          default(TRUE)
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

require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
