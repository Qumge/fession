require_relative 'boot'

require 'rails/all'
require'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Fission
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.active_record.belongs_to_required_by_default = false
    config.autoload_paths << "#{Rails.root}/lib"
    config.assets.precompile += %w(swagger_ui.js swagger_ui.css swagger_ui_print.css swagger_ui_screen.css)
    config.time_zone = 'Beijing'
    config.active_record.default_timezone = :local
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', 'zh-CN', '*.yml').to_s]
    config.i18n.available_locales = [:en, 'zh-CN']
    config.i18n.default_locale = 'zh-CN'

    # config.middleware.insert_before 0, Rack::Cors do
    #   allow do
    #     origins '*'
    #     resource '*', :headers => :any, :methods => [:get, :post, :options, :patch, :put, :delete]
    #   end
    # end
    config.eager_load_paths += %W(#{Rails.root.join}/lib)
  end
end
