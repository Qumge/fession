# == Schema Information
#
# Table name: spec_values
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  spec_id    :integer
#

class SpecValue < ApplicationRecord
  belongs_to :spec
  validates_presence_of :name
  validates_uniqueness_of :name, scope: :spec_id

  def product
    self.spec&.product
  end

end
