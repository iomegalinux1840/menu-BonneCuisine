require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MenuBonneCuisine
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = 'Paris'
    # config.eager_load_paths << Rails.root.join("extras")

    # Removed lib from autoload paths since constraints are now inline in routes.rb
    # to avoid production autoloading issues

    # Configure subdomain handling for development
    config.action_dispatch.tld_length = 0 # For localhost

    # ActionCable configuration
    config.action_cable.mount_path = '/cable'
    config.action_cable.url = 'ws://localhost:3000/cable'
    config.action_cable.allowed_request_origins = ['http://localhost:3000', 'https://localhost:3000']
  end
end