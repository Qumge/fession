# == Schema Information
#
# Table name: sms_records
#
#  id             :bigint           not null, primary key
#  code           :string(255)
#  message        :string(255)
#  params         :string(255)
#  phone          :string(255)
#  sign           :string(255)
#  status         :string(255)
#  up_extend_code :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  biz_id         :string(255)
#  out_id         :string(255)
#  region_id      :string(255)
#  request_id     :string(255)
#

class SmsRecord < ApplicationRecord

  after_create :send_sms


  def send_sms
    begin
      res = SmsRecord.client.request(
          action: 'SendSms',
          params: {
              "RegionId": region_id,
              "PhoneNumbers": phone,
              "SignName": sign,
              "TemplateCode": code,
              "TemplateParam": params.to_s,
              "SmsUpExtendCode": up_extend_code.to_s,
              "OutId": out_id.to_s
          },
          opts: {
              method: 'POST'
          }
      )
      self.update message: res['Message'], request_id: res['RequestId'], biz_id: res['BizId'], status: res['Code']
    rescue => e
      p e.messages
    end

  end

  class << self
    def client
      RPCClient.new(
          access_key_id:     Settings.aliyun_key_id,
          access_key_secret: Settings.aliyun_key_secret,
          endpoint: 'https://dysmsapi.aliyuncs.com',
          api_version: '2017-05-25'
      )
    end
  end

end
