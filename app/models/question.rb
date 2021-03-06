# == Schema Information
#
# Table name: questions
#
#  id               :bigint           not null, primary key
#  name             :string(255)
#  type             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  questionnaire_id :integer
#

class Question < ApplicationRecord
  has_many :options
  has_many :answers
end
