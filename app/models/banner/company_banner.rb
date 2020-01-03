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

class Banner::CompanyBanner < Banner
  before_create :set_no
  belongs_to :company

  def set_no
    self.no = Banner::CompanyBanner.maximum(:no).to_i + 1
  end

end
