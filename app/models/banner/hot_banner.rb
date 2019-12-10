class Banner::HotBanner < Banner
  before_create :set_no

  def set_no
    self.no = Banner::HotBanner.maximum(:no).to_i + 1
  end

end