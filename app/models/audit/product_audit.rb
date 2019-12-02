class Audit::ProductAudit < Audit
  belongs_to :product, foreign_key: :model_id
end