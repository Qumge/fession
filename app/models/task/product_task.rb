# == Schema Information
#
# Table name: tasks
#
#  id           :bigint           not null, primary key
#  amount       :integer          default(0)
#  coin         :bigint
#  commission   :integer
#  deleted_at   :datetime
#  name         :string(255)
#  number       :integer          default(0)
#  residue_coin :bigint
#  sale         :integer          default(0)
#  sale_coin    :integer          default(0)
#  share_link   :string(255)
#  share_num    :integer          default(0)
#  status       :string(255)
#  type         :string(255)
#  valid_from   :datetime
#  valid_to     :datetime
#  view_num     :integer          default(0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  company_id   :integer
#  model_id     :integer
#
# Indexes
#
#  index_tasks_on_deleted_at  (deleted_at)
#

class Task::ProductTask < Task
  belongs_to :product, foreign_key: :model_id
  before_save :set_name
  # validates_uniqueness_of :model_id
  def view_name
    self.product&.name
  end

  def h5_path
    "/pages/product/show?id=#{self.model_id}"
  end

  class << self
    def search_conn params
      s = super
      if params[:name].present?
        s = s.joins(:product).where('products.name like ?', "%#{params[:name]}%")
      end
      s
    end
  end

  def set_name
    self.name = self.product.name
  end

end
