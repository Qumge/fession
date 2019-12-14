module V1
  module Users
    class ShareRules < Grape::API
      helpers V1::Users::UserLoginHelper
      include Grape::Kaminari

      resources 'share_rules' do
        desc '分享规则列表'
        get '/' do
          share_rules = ::ShareRule.order('level asc')
          present share_rules, with: V1::Entities::ShareRule
        end
      end
    end
  end
end