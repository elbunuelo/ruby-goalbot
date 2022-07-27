require_relative 'boot'

require 'rails/all'
require 'rake'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RubyGoalbot
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = 'America/Bogota'
    # config.eager_load_paths << Rails.root.join("extras")
    #
    config.after_initialize do
      Rails.logger.info '[Application] Scheduling day events fetch.'
      Resque.set_schedule(
        'day_events',
        {
          class: 'FetchDayEvents',
          persist: true,
          every: ['6h', { first_in: '1s' }]
        }
      )
    end
  end
end