module V1
  module Admins
    class Admins < Grape::API
      helpers AdminLoginHelper
      helpers QiniuHelper
      resources 'admins' do
        desc '登录 登录成功将返回的authentication_token  之后请求时将 authentication_token写入header的 X-Auth-Token 里面'
        params do
          requires :login, type: String, desc: '登录账号'
          requires :password, type: String, desc: '密码'
        end
        post "/login" do
          @admin = Admin.find_by_login params[:login]

          if @admin.present?
            if @admin.locked?
              {error: '20002', message: '账号已冻结，不能登录，请联系管理员'}
            else
              if @admin.class.name == 'Customer'
                if @admin.company.present?
                  if @admin.company.locked?
                    {error: '20004', message: '商户已被冻结，请联系管理员'}
                  else
                    if @admin.valid_password? params[:password]
                      @admin.ensure_authentication_token!
                      {login: @admin.login, id: @admin.id, authentication_token: @admin.authentication_token, type: @admin.type, role_name: @admin.role&.name}
                    else
                      {error: '20003', message: '账号或密码错误'}
                    end
                  end
                else
                  {error: '20003', message: '错误的商户账号'}
                end
              else
                if @admin.valid_password? params[:password]
                  @admin.ensure_authentication_token!
                  {login: @admin.login, id: @admin.id, authentication_token: @admin.authentication_token, type: @admin.type, role_name: @admin.role&.name}
                else
                  {error: '20003', message: '账号或密码错误'}
                end
              end
            end
          else
            {error: '20001', message: '账号或密码错误'}
          end
        end

        desc '忘记密码  通过手机号码 发送密码'
        params do
          requires :login, type: String, desc: '登录账号手机号'
          requires :type, type:String, desc: "类型 {Customer: '商户', Operator: '运营账号'}" 
        end
        post 'forget_password'  do
          case params[:type]
          when 'Customer'
            model = Customer
          when 'Operator'
            model = Operator
          else
            return {error: '30002', message: '类型错误'}
          end
          admin = model.find_by login: params[:login]
          if admin.present?
            admin.send_password
            {error: '', message: '密码已经发送到您的手机号'}
          else
            {error: '30001', message: '找不到账号'}
          end
        end
      end
    end
  end

end