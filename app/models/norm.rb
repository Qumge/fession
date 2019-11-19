# == Schema Information
#
# Table name: norms
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  price      :integer
#  sale       :integer          default(0)
#  spec_attrs :string(255)
#  stock      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :integer
#

class Norm < ApplicationRecord
  validates_presence_of :price
  belongs_to :product

  def spec_values
    SpecValue.where(id: (self.spec_attrs.present? ? self.spec_attrs.split('/') : 0))
  end

  def spec_attr_names
    spec_values.pluck(:name).join('/')
  end
end
