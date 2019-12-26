class Express

  class << self
    def result no, type
      p Settings.express.app_code
      r = RestClient::Request.execute(
          method: :get,
          url: "https://wuliu.market.alicloudapi.com/kdi",
          headers: { params: {no: no, type: type}, Authorization: "APPCODE #{Settings.express.app_code}" }
      )
    end
  end


end