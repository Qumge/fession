module V1
  module Admins
    module AdminLoginHelper
      extend Grape::API::Helpers
      def current_admin
        #p env["HTTP_X_USER_ACCESS_TOKEN"], 1111111
        @current_admin ||= request.headers['Admin_Authentication_Token'].nil? ? nil : Admin.find_by_authentication_token(request.headers['Admin_Authentication_Token'])
      end

      def authenticate!
        unless current_admin
          #logger.debug "authenticate fail with HTTP_X_USER_ACCESS_TOKEN #{env['HTTP_X_USER_ACCESS_TOKEN']} "
          error!("401 Unauthorized", 401)
        end
      end
    end
  end
end