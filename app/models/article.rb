# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  content    :text(65535)
#  subject    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#  product_id :integer
#

class Article < ApplicationRecord
  belongs_to :article
  belongs_to :company
  belongs_to :product
end
