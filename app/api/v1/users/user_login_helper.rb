module V1
  module Users
    module UserLoginHelper
      extend Grape::API::Helpers
      def current_user
        #p env["HTTP_X_USER_ACCESS_TOKEN"], 1111111
        @current_user ||= request.headers['X-Auth-Token'].nil? ? nil : User.find_by_authentication_token(request.headers['X-Auth-Token'])
      end

      def authenticate!
        unless current_user
          #logger.debug "authenticate fail with HTTP_X_USER_ACCESS_TOKEN #{env['HTTP_X_USER_ACCESS_TOKEN']} "
          error!("401 Unauthorized", 401)
        end
      end
    end
  end
end