class Audit::TaskAudit < Audit
  belongs_to :task, foreign_key: :model_id
end