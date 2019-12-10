require 'openssl'
require 'base64'
module V1
  module Entities
    class Post < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id do |instance, options|
        cipher = OpenSSL::Cipher::Cipher.new('AES-256-CBC')
        cipher.iv = ['1e5673b2572af26a8364a50af84c7d2a'].pack('H*')
        cipher.encrypt()
        cipher.key = '5gA6lgr5g3GOg7EOQ1caYQddddsasasdasmdklamsdlm'
        crypt = cipher.update('s') + cipher.final()
        crypt_string = (Base64.encode64(crypt))
        crypt_string
      end
      expose :title
      expose :content
      expose :status
      expose :get_status
      expose :number
      expose :user, using: V1::Entities::User
      expose :images, using: V1::Entities::Image
      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end