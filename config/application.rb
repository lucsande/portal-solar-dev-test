require_relative 'boot'
require 'rails/all'

Bundler.require(*Rails.groups)

module PortalSolarDevTest
  class Application < Rails::Application
    config.action_view.embed_authenticity_token_in_remote_forms = true
    config.load_defaults 5.2
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
  end
end
