class Banner::PostBanner < Banner
  before_create :set_no

  def set_no
    self.no = Banner::PostBanner.maximum(:no).to_i + 1
  end

end