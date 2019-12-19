
WxPay.mch_id = '1565525921'
WxPay.appid = 'wx202bddcd868b179f'
WxPay.key = 'B7d1305mB7d1305mB7d1305mB7d1305m'

# 下面这句没有用. TODO .删掉它.
#WxPay.set_apiclient_by_pkcs12(File.read(pkcs12_filepath), pass)

WxPay.extra_rest_client_options = {timeout: 2, open_timeout: 3}