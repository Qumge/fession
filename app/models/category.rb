# == Schema Information
#
# Table name: categories
#
#  id         :bigint           not null, primary key
#  ancestry   :string(255)
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Category < ApplicationRecord
  has_ancestry
  acts_as_paranoid
  has_many :products

  validates_presence_of :name
  validates_uniqueness_of :name

  validate do |category|
    category.high_depth
  end

  def high_depth
    errors.add(:ancestry, '过深的层级') if self.depth > 1
  end

end
