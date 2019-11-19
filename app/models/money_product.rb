# == Schema Information
#
# Table name: products
#
#  id          :bigint           not null, primary key
#  coin        :integer
#  desc        :text(65535)
#  name        :string(255)
#  no          :string(255)
#  price       :integer
#  sale        :integer          default(0)
#  status      :string(255)
#  stock       :integer          default(0)
#  type        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :integer
#  company_id  :integer
#

class MoneyProduct < Product
  #validates_presence_of :norms
  #

  def stock
    self.norms.sum(:stock)
  end

  def price
    self.norms.order(:price).first&.price
  end
end
