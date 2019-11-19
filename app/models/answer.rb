# == Schema Information
#
# Table name: answers
#
#  id               :bigint           not null, primary key
#  content          :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  option_id        :integer
#  question_id      :integer
#  questionnaire_id :integer
#  user_id          :integer
#

class Answer < ApplicationRecord
end
