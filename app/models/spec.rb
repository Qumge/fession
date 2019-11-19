# == Schema Information
#
# Table name: specs
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :integer
#

class Spec < ApplicationRecord
  belongs_to :money_product
  validates_presence_of :name
  validates_uniqueness_of :name, scope: :product_id
  has_many :spec_values
end
