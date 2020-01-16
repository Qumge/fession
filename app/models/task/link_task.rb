# == Schema Information
#
# Table name: tasks
#
#  id           :bigint           not null, primary key
#  amount       :integer          default(0)
#  coin         :bigint
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

class Task::LinkTask < Task
  #belongs_to :article, foreign_key: :model_id
  after_create_commit :set_success
  def view_name
    self&.name
  end

  def set_success
    self.update status: 'success', residue_coin: self.coin
  end

  def h5_path
    "/pages/task/share_link?id=#{self.id}"
  end



end
