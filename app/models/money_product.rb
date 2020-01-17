# == Schema Information
#
# Table name: products
#
#  id          :bigint           not null, primary key
#  amount      :integer          default(0)
#  coin        :integer
#  deleted_at  :datetime
#  desc        :text(65535)
#  name        :string(255)
#  no          :string(255)
#  price       :integer
#  sale        :integer          default(0)
#  sale_coin   :integer          default(0)
#  status      :string(255)
#  stock       :integer          default(0)
#  type        :string(255)
#  view_num    :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :integer
#  company_id  :integer
#
# Indexes
#
#  index_products_on_deleted_at  (deleted_at)
#

class MoneyProduct < Product
  validates_presence_of :company_id
  validates_presence_of :specs
  #validates_presence_of :norms
  #

  def stock
    self.norms.sum(:stock)
  end

  def view_price
    self.price.to_f / 100
  end
end
