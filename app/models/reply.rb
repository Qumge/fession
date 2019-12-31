class Reply < ApplicationRecord
  belongs_to :user
  belongs_to :questionnaire
  has_many :answers
end
