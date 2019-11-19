module V1
  module Admins
    class Tasks < Grape::API
      helpers V1::Admins::AdminLoginHelper
      before do
        authenticate!
      end
      resources 'product_tasks' do

        desc '创建商品任务', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :product_id, type: Integer, desc: '产品id'
          requires :coin, type: Integer, desc: '金币总数'
          requires :valid_from, type: DateTime, desc: '有效期始'
          requires :valid_to, type: DateTime, desc: '有效至'
        end
        post '/' do
          task = Task::Product.new model_id: params[:product_id], coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to], company: @company
          if task.save
            present task, with: V1::Entities::Task
          end
        end

        route_param :id do
          before do
            @task = Task::Product.find_by id: params[:id]
          end

          desc '商品任务变更', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires :product_id, type: Integer, desc: '产品id'
            requires :coin, type: Integer, desc: '金币总数'
            requires :valid_from, type: DateTime, desc: '有效期始'
            requires :valid_to, type: DateTime, desc: '有效至'
          end
          patch '/' do
            if @task.update model_id: params[:product_id], coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to], company: @company
              present @task, with: V1::Entities::Task
            else
              {code: '100001', error_message: @task.errors}
            end
          end

          desc '商品任务详情', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          get '/' do
            present @task, with: V1::Entities::Task
          end
        end
      end


      resources 'article_tasks' do

        desc '创建推文任务', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :product_id, type: Integer, desc: '关联商品id'
          requires :subject, type: String, desc: '标题'
          requires :content, type: String, desc: '内容'
          requires :coin, type: Integer, desc: '金币总数'
          requires :valid_from, type: DateTime, desc: '有效期始'
          requires :valid_to, type: DateTime, desc: '有效至'
        end
        post '/' do
          article = ::Article.new prodcut_id: params[:product_id], company: @company, subject: params[:subject], content: params[:content]
          task = Task::Article.new article: article, coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to], company: @company
          if task.save
            present task, with: V1::Entities::Task
          end
        end

        route_param :id do
          before do
            @task = Task::Article.find_by id: params[:id]
          end

          desc '推文任务变更', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires :product_id, type: Integer, desc: '产品id'
            requires :coin, type: Integer, desc: '金币总数'
            requires :valid_from, type: DateTime, desc: '有效期始'
            requires :valid_to, type: DateTime, desc: '有效至'
          end
          patch '/' do
            article = @task.article
            article.attributes = {prodcut_id: params[:product_id], company: @company, subject: params[:subject], content: params[:content]}
            if @task.update article: article, coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to], company: @company
              present @task, with: V1::Entities::Task
            else
              {code: '100001', error_message: @task.errors}
            end
          end

          desc '商品任务详情', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          get '/' do
            present @task, with: V1::Entities::Task
          end
        end
      end


      resources 'questionnaire_tasks' do

        desc '创建调查问卷任务', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :name, type: String, desc: '标题'
          optional :desc, type: String, desc: '备注 描述'
          optional :questions, type: Array[Hash], desc: "问题 [{name: '玩过的游戏', type: 'Question::Multiple', options: ['dnf', 'dota', 'lol']}, {name: '性别', type: 'Question::Single', options: ['男', '女']}, {name: '建议', type: 'Question::Completion'}]", default: [{name: '玩过的游戏', type: 'Question::Multiple', options: ['dnf', 'dota', 'lol']}, {name: '性别', type: 'Option::Single', options: ['男', '女']}, {name: '建议', type: 'Question::Completion'}]
          requires :coin, type: Integer, desc: '金币总数'
          requires :valid_from, type: DateTime, desc: '有效期始'
          requires :valid_to, type: DateTime, desc: '有效至'
        end
        post '/' do
          questionnaire = ::Questionnaire.new name: params[:name], desc: params[:desc]
          questionnaire = questionnaire.fetch_questions params[:questions]
          p Task::Questionnaire.name, 1111111
          task = Task.new type: 'Task::Questionnaire', coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to], company: @company, questionnaire: questionnaire

          if questionnaire.valid?
            if task.save
              present task, with: V1::Entities::Task
            else
              {error_code: '100001', error_message: task.errors}
            end
          else
            {error_code: '100001', error_message: questionnaire.errors}
          end
        end

        route_param :id do
          before do
            p Task::Questionnaire.name
            @task = Task::Questionnaire.find_by id: params[:id]
          end
          desc '问卷任务变更', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires :product_id, type: Integer, desc: '产品id'
            requires :coin, type: Integer, desc: '金币总数'
            requires :valid_form, type: DateTime, desc: '有效期始'
            requires :valid_to, type: DateTime, desc: '有效至'
          end
          patch '/' do
            if @task.update model_id: params[:article_id], coin: params[:coin], valid_form: params[:valid_form], valid_to: params[:valid_to], company: @company
              present task, with: V1::Entities::Task
            else
              {code: '100001', error_message: @task.errors}
            end
          end

          desc '商品任务详情', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          get '/' do
            present @task, with: V1::Entities::Task
          end
        end
      end




    end
  end
end