class Banner::CompanyBanner < Banner
  before_create :set_no
  belongs_to :company

  def set_no
    self.no = Banner::CompanyBanner.maximum(:no).to_i + 1
  end

end