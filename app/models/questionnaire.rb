# == Schema Information
#
# Table name: questionnaires
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  desc       :string(255)
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#
# Indexes
#
#  index_questionnaires_on_deleted_at  (deleted_at)
#

class Questionnaire < ApplicationRecord
  has_many :questions
  has_one :task
  belongs_to :company
  has_one :task_questionnaire_task, :class_name => 'Task::QuestionnaireTask', foreign_key: 'model_id'
  has_many :replies
  has_many :answers
  def fetch_questions params_questions
    # params_questions = params[:questions]
    #params_questions = [{name: '玩过的游戏', type: 'Question::Multiple', options: ['dnf', 'dota', 'lol']}, {name: '性别', type: 'Question::Single', options: ['男', '女']}, {name: '建议', type: 'Question::Completion'}]
    questions = []
    params_questions.each do |params_question|
      p params_question, 111111
      question = self.questions.find_or_initialize_by name: params_question['name']
      question.type = params_question['type']
      options = []
      if params_question['options'].present?
        params_question['options'].each do |name|
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

  def stat_answers
    stat_questions = []
    self.questions.each do |question|
      if question.type == 'Question::Completion'
        stat_options = question.answers.pluck :content
        stat_questions << {question_name: question.name, type: 'content', options: stat_options}
      else
        stat_options = []
        question.options.each do |option|
          stat_options << {name: option.name, number: option.answers.size}
        end
        stat_questions << {question_name: question.name, type: 'option', options: stat_options}
      end
    end
    stat_questions
  end

end
