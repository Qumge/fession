class FissionLog < ApplicationRecord
  has_ancestry

  belongs_to :user
  belongs_to :task
  has_many :share_logs


  has_many :audits, foreign_key: :model_id


  class << self
    def assign_coin

    end
  end

end
