# == Schema Information
#
# Table name: banners
#
#  id         :bigint           not null, primary key
#  no         :integer
#  type       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#  task_id    :integer
#

class Banner < ApplicationRecord
  has_one :image, -> {where(model_type: 'Banner')}, foreign_key: :model_id
  belongs_to :task, foreign_key: :task_id
  belongs_to :post, foreign_key: :task_id

  def fetch_params params
    image = Image.new file_path: params[:image], model_type: 'Banner'
    self.update image: image, task_id: params[:task_id]
    self
  end

  def up
    head = self.class.where('no < ?', self.no).order('no').last
    if head.present?
      no = head.no
      head.update no: self.no
      self.update no: no
    end

  end

  def down
    foot = self.class.where('no > ?', self.no).order('no').first
    if foot.present?
      no = foot.no
      foot.update no: self.no
      self.update no: no
    end
  end

end
