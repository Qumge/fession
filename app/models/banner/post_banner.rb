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

class Banner::PostBanner < Banner
  before_create :set_no

  def set_no
    self.no = Banner::PostBanner.maximum(:no).to_i + 1
  end

end
