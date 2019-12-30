module V1
  module Users
    module UserLoginHelper
      extend Grape::API::Helpers
      def current_user
        #p env["HTTP_X_USER_ACCESS_TOKEN"], 1111111
        @current_user ||= request.headers['X-Auth-Token'].nil? ? nil : User.find_by_authentication_token(request.headers['X-Auth-Token'])
      end

      def authenticate!
        p request.headers['X-Auth-Token'], 111111111
        unless current_user
          p 222222222
          #logger.debug "authenticate fail with HTTP_X_USER_ACCESS_TOKEN #{env['HTTP_X_USER_ACCESS_TOKEN']} "
          error!("401 Unauthorized", 401)
        else
          @current_user.update last_active_at: DateTime.now
        end
      end
    end
  end
end