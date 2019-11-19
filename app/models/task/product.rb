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

class Task::Product < Task
  belongs_to :product, foreign_key: :model_id
end
