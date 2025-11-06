require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Nezhdanchik
  class Application < Rails::Application
    config.load_defaults 7.2
    config.hosts.clear

    config.time_zone = "Minsk"

    config.autoload_lib(ignore: %w[assets tasks])
    config.i18n.default_locale = :ru

    Avo.configure do |config|
      config.locale = :ru
    end
  end
end
