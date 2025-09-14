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

    # Add lib directory to autoload paths for constraints
    config.autoload_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('lib')

    # ActionCable configuration
    config.action_cable.mount_path = '/cable'
    config.action_cable.url = 'ws://localhost:3000/cable'
    config.action_cable.allowed_request_origins = ['http://localhost:3000', 'https://localhost:3000']
  end
end