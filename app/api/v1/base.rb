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
        mount V1::Admins::Game
        mount V1::Admins::TaskGameWheels
      end

      namespace :users do
        mount V1::Users::Users
      end

      add_swagger_documentation(
          :api_version => "api/v1",
          hide_documentation_path: true,
          hide_format: true
      )
    end
end
