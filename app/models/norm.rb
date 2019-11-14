# == Schema Information
#
# Table name: norms
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  price      :integer
#  sale       :integer          default(0)
#  stock      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :integer
#

class Norm < ApplicationRecord
  validates_presence_of :price
  belongs_to :product
end
