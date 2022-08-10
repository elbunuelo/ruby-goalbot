require_relative 'boot'

require 'rails/all'
require 'rake'

require 'configatron'

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

    configatron.reddit.secret = ENV['REDDIT_SECRET'].freeze
    configatron.reddit.client_id = ENV['REDDIT_CLIENT_ID'].freeze
    configatron.reddit.user_agent = ENV['BOT_USER_AGENT'].freeze
    configatron.reddit.interval = 60.seconds

    configatron.api.url = ENV['API_URL'].freeze

    configatron.redis.url = ENV['REDIS_URL'].freeze

    configatron.hangouts.callback_url = ENV['HANGOUTS_CALLBACK_URL'].freeze
    configatron.hangouts.api_key = ENV['HANGOUTS_API_KEY'].freeze

    config.sass.preferred_syntax = :sass
    config.sass.line_comments = false
    config.sass.cache = false

    I18n.available_locales = %i[en es]
    I18n.default_locale = :en
  end
end
