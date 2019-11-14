module V1
  module Admins
    module AdminLoginHelper
      extend Grape::API::Helpers
      def current_admin
        #p env["HTTP_X_USER_ACCESS_TOKEN"], 1111111
        p params, 111
        @current_admin ||= request.headers['X-Auth-Token'].nil? ? nil : Admin.find_by_authentication_token(request.headers['X-Auth-Token'])
      end

      def authenticate!
        if current_admin
          #logger.debug "authenticate fail with HTTP_X_USER_ACCESS_TOKEN #{env['HTTP_X_USER_ACCESS_TOKEN']} "
          @company = @current_admin.company
        else
          error!("401 Unauthorized", 401)
        end
      end
    end
  end
end