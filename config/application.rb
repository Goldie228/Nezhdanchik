require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Nezhdanchik
  class Application < Rails::Application
    config.load_defaults 7.2

    config.autoload_lib(ignore: %w[assets tasks])

    Avo.configure do |config|
      config.locale = :ru
    end
  end
end
