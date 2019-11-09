module V1
  module Admins
    class Companies < Grape::API
      helpers V1::Admins::AdminLoginHelper
      resources 'Companies' do
        desc '创建商户'
        params do
          requires 'name', type: String, desc: '商户名'
          requires 'login', type: String, desc: '商户账号'
          requires 'password', type: String, desc: '密码'
        end
        post '/' do
          company = Company.new name: name
        end
      end
    end
  end
end