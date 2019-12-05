
module V1
    class Base < Grape::API
      version 'v1', using: :path
      namespace :admins do
        mount V1::Admins::Admins
        mount V1::Admins::Companies
        mount V1::Admins::Categories
        mount V1::Admins::Operators
        mount V1::Admins::Roles
        mount V1::Admins::Products
        mount V1::Admins::TaskProducts
        mount V1::Admins::TaskArticles
        mount V1::Admins::TaskQuestionnaires
        mount V1::Admins::Games
        mount V1::Admins::TaskGames
        mount V1::Admins::Qiniu
        mount V1::Admins::Audits
      end

      namespace :users do
        mount V1::Users::Users
        mount V1::Users::Qiniu
        mount V1::Users::Fissions
        mount V1::Users::TaskArticles
        mount V1::Users::TaskQuestionnaires
        mount V1::Users::Products
      end

      add_swagger_documentation(
          :api_version => "api/v1",
          hide_documentation_path: true,
          hide_format: true
      )
    end
end
