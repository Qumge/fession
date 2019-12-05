# == Schema Information
#
# Table name: audits
#
#  id          :bigint           not null, primary key
#  form_status :string(255)
#  reason      :text(65535)
#  to_status   :string(255)
#  type        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  admin_id    :integer
#  model_id    :integer
#

class Audit::TaskAudit < Audit
  belongs_to :task, foreign_key: :model_id
end
