class ShareLog < ApplicationRecord
  after_create :fission_coin

  def fission_coin

  end

end
