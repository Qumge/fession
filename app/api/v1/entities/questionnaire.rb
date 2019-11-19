module V1
  module Entities
    class Questionnaire < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d' }
      #format_with(:parent) { |dt| instance.parent.name }
      expose :id
      expose :name
      expose :company, using: V1::Entities::Company
      expose :questions, using: V1::Entities::Question
      expose :desc

      # product_category 是在rails的model中定义的关联，在这里可以直接用
      with_options(format_with: :timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end