# == Schema Information
#
# Table name: images
#
#  id         :bigint           not null, primary key
#  file_path  :string(255)
#  model_type :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  model_id   :integer
#

class Image < ApplicationRecord
  validates_presence_of :file_path

  def image_path
    Rails.application.config.qiniu_domain + file_path
  end

end
