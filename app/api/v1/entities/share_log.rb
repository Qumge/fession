module V1
  module Entities
    class ShareLog < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :task_name
      expose :fission_log_id
      expose :token
      expose :user_id
      expose :user_name
      expose :company_name
      expose :from_user_name
      # expose :coin do |instance, options|
      #   user = options[:user]
      #   if user.present?
      #     coin_log = CoinLog.find_by user: user, share_log: instance, channel: 'fission'
      #     coin_log&.coin
      #   else
      #     ''
      #   end
      # end
      with_options(format_with: :timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end