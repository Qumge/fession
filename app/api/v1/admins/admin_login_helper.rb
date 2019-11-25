module V1
  module Admins
    module AdminLoginHelper
      extend Grape::API::Helpers
      def current_admin
        #p env["HTTP_X_USER_ACCESS_TOKEN"], 1111111
        p params, 111
        p request.headers['X-Auth-Token']
        @current_admin ||= request.headers['X-Auth-Token'].nil? ? nil : Admin.find_by_authentication_token(request.headers['X-Auth-Token'])
        p @current_admin
      end

      def authenticate!
        if current_admin
          #logger.debug "authenticate fail with HTTP_X_USER_ACCESS_TOKEN #{env['HTTP_X_USER_ACCESS_TOKEN']} "
          @company = @current_admin.company if @current_admin.type != 'Customer'
          #验证商户权限
        else
          error!("401 Unauthorized", 401)
        end
      end

      def operator_auth!
        error!("无权限", 500) if @current_admin.type != 'Operator'
      end
    end
  end
end