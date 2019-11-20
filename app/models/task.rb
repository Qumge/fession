# == Schema Information
#
# Table name: tasks
#
#  id           :bigint           not null, primary key
#  coin         :bigint
#  name         :string(255)
#  residue_coin :bigint
#  status       :string(255)
#  type         :string(255)
#  valid_form   :datetime
#  valid_to     :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  company_id   :integer
#  model_id     :integer
#

class Task < ApplicationRecord
  include AASM
  before_create :set_residue
  belongs_to :company

  def set_residue
    self.residue_coin = self.coin
  end
end