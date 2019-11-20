# == Schema Information
#
# Table name: questionnaires
#
#  id         :bigint           not null, primary key
#  desc       :string(255)
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#

class Questionnaire < ApplicationRecord
  has_many :questions
  has_one :task
  belongs_to :company
  def fetch_questions params_questions
    # params_questions = params[:questions]
    params_questions = [{name: '玩过的游戏', type: 'Option::Multiple', options: ['dnf', 'dota', 'lol']}, {name: '性别', type: 'Question::Single', options: ['男', '女']}, {name: '建议', type: 'Question::Completion'}]
    questions = []
    params_questions.each do |params_question|
      question = self.questions.find_or_initialize_by name: params_question[:name]
      question.type = params_question[:type]
      options = []
      if params_question[:options].present?
        params_question[:options].each do |name|
          p name, 1111
          option = question.options.find_or_initialize_by name: name
          options << option
        end
        question.options = options
      end
      questions << question
    end
    self.questions = questions
    self.save
    self
  end

end