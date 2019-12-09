class Banner < ApplicationRecord
  has_one :image, -> {where(model_type: 'Banner')}, foreign_key: :model_id
  belongs_to :task
end
