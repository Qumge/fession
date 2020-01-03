# == Schema Information
#
# Table name: replies
#
#  id               :bigint           not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  questionnaire_id :integer
#  user_id          :integer
#

class Reply < ApplicationRecord
  belongs_to :user
  belongs_to :questionnaire
  has_many :answers
end
