require 'qiniu'

Qiniu.establish_connection! :access_key => Settings.qiniu.access_key,
                            :secret_key => Settings.qiniu.secret_key

Rails.application.config.qiniu_domain = "http://qutu.longshengpm.com"
