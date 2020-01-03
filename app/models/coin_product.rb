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

class CoinProduct < Product
  # validates_presence_of :coin
  validates_presence_of :name
  after_create :set_status

  def set_status
    self.update status: 'up'
  end
end
