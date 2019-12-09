class Banner::TaskBanner < Banner
  before_create :set_no

  def set_no
    self.no = Banner::TaskBanner.maximum(:no).to_i + 1
  end
end