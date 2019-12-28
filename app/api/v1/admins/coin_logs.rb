module V1
  module Admins
    class CoinLogs < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end

      
    end
  end
end
