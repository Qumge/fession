module V1
  module Entities
    class Task < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d' }
      #format_with(:parent) { |dt| instance.parent.name }
      expose :id
      expose :name
      expose :company, using: V1::Entities::Company
      expose :product, using: V1::Entities::Product, if: proc{|instance| instance.type == 'Task::ProductTask'}
      expose :game, using: V1::Entities::Game, if: proc{|instance| instance.type == 'Task::GameTask'}
      expose :article, using: V1::Entities::Article, if: proc{|instance| instance.type == 'Task::ArticleTask'}
      expose :questionnaire, using: V1::Entities::Questionnaire, if: proc{|instance| instance.type == 'Task::QuestionnaireTask'}
      expose :status
      expose :coin
      expose :residue_coin

      # product_category 是在rails的model中定义的关联，在这里可以直接用
      with_options(format_with: :timestamp) do
        expose :valid_from
        expose :valid_to
      end
      with_options(format_with: :timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end