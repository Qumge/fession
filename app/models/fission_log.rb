class FissionLog < ApplicationRecord
  belongs_to :user
  belongs_to :task

  has_many :audits, foreign_key: :model_id

  class << self

  end

end
