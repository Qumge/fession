# == Schema Information
#
# Table name: options
#
#  id          :bigint           not null, primary key
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  question_id :integer
#

class Option < ApplicationRecord
end
