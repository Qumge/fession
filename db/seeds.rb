# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin = Operator.find_or_initialize_by login: '13585665936'
admin.password = '123456'
admin.save
role = Role.find_or_create_by name: '超级管理员'
resources = ["平台管理", "平台游戏", "提现管理", "广告位配置", "签到配置", "奖励规则", "地址库", "首页", "商品管理", "商家商品", "金币商城", "商品分类", "订单管理", "平台订单", "商户订单", "任务管理", "商品任务", "游戏任务", "调查任务", "阅读任务", "发布管理", "商户管理", "数据管理", "任务数据", "用户数据", "商户数据", "交易数据", "系统管理", "账号管理", "角色管理", "日志管理"]
resources.each do |name|
  Resource.find_or_create_by name: name
end
role.resources = Resource.all
