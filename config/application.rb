require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Rn
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2
    # for testing error pages (bypasses the internal error logic)
    config.exceptions_app = self.routes
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.eager_load_paths << Rails.root.join("extras")
    # Desde Rails 7.1 `allowed_tags`/`allowed_attributes` valen nil por defecto
    # (significa "usar los del sanitizer"), así que hay que partir de esos
    # valores base en lugar de mutarlos in-place.
    config.after_initialize do
      helper = ActionText::ContentHelper

      helper.allowed_attributes =
        helper.sanitizer.class.allowed_attributes +
        ActionText::Attachment::ATTRIBUTES +
        %w[style controls poster]

      helper.allowed_tags =
        helper.sanitizer.class.allowed_tags +
        [ActionText::Attachment.tag_name, 'figure', 'figcaption'] +
        %w[video audio source embed iframe]
    end
  end
end
