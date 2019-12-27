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

  belongs_to :question
  belongs_to :option
  belongs_to :user
  belongs_to :questionnaire
  class << self
    def fetch_params user, questionnaire, params
      answers = JSON.parse params[:answer]
      self.transaction do
        begin
          current_answers = Answer.where(questionnaire: questionnaire, user: user)
          raise '您已经回答过这个问卷了' if current_answers.present?
          answers.each do |answer|
            p answer['question_id'], 111
            question = questionnaire.questions.find_by id: answer['question_id']
            raise '数据错误： 问题不存在' unless question.present?
            case question.type
            when 'Question::Completion'
              self.create question: question, questionnaire: questionnaire, user: user, content: answer[]
            when 'Question::Multiple'
              option_ids = answer['option_id']
              option_ids.each do |option_id|
                option = question.options.find_by id: option_id
                raise '数据错误 选项不存在' unless option.present?
                self.create option: option, question: question, questionnaire: questionnaire, user: user
              end
            when 'Question::Single'
              option = question.options.find_by id: answer['option_id'].first
              raise '数据错误 选项不存在' unless option.present?
              self.create option: option, question: question, questionnaire: questionnaire, user: user
            end
          end
          Answer.where(questionnaire: questionnaire, user: user)
        rescue => e
          {error: '30001', message: e.message}
        end
      end
    end
  end

end
