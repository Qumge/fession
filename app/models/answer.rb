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
#  reply_id         :integer
#  user_id          :integer
#

class Answer < ApplicationRecord

  belongs_to :question
  belongs_to :option
  belongs_to :user
  belongs_to :questionnaire
  belongs_to :reply

  class << self
    def fetch_params user, questionnaire, params
      p user, questionnaire, 22222222
      answers = JSON.parse params[:answer]
      self.transaction do
        begin
          reply = questionnaire.replies.find_by user: user
          raise '您已经回答过这个问卷了' if reply.present?
          reply = questionnaire.replies.new user: user
          p reply, 1111
          answers.each do |question_id, value|
            question = questionnaire.questions.find_by id: question_id
            raise '数据错误： 问题不存在' unless question.present?
            case question.type
            when 'Question::Completion'
              reply.answers.new question: question, questionnaire: questionnaire, user: user, content: value
            when 'Question::Multiple'
              value.each do |option_id|
                option = question.options.find_by id: option_id
                raise '数据错误 选项不存在' unless option.present?
                reply.answers.new option: option, question: question, questionnaire: questionnaire, user: user
              end
            when 'Question::Single'
              option = question.options.find_by id: value
              raise '数据错误 选项不存在' unless option.present?
              reply.answers.new option: option, question: question, questionnaire: questionnaire, user: user
            end
          end
          reply.save
        rescue => e
          {error: '30001', message: e.message}
        end
      end
    end
  end

end
