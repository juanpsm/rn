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

    # Rails usa libvips por defecto, pero no está instalado ni en las máquinas
    # de desarrollo ni en los runners de GitHub Actions; ImageMagick sí. Sin
    # este cambio, generar la miniatura del avatar falla.
    config.active_storage.variant_processor = :mini_magick
    # Se amplía el safelist de ActionText para poder embeber audio y video en
    # las notas.
    #
    # `iframe` y `embed` quedan deliberadamente fuera: permiten incrustar una
    # página o un plugin arbitrarios dentro de la nota, lo que habilita
    # clickjacking y phishing almacenado. `video`/`audio`/`source` cubren el
    # caso de uso real sin esa superficie de ataque.
    #
    # `style` sí se mantiene: el safe_list_sanitizer filtra el contenido del
    # atributo contra un safelist de propiedades CSS y descarta las peligrosas
    # (`position`, `z-index`, etc.), así que no permite montar overlays.
    #
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
        %w[video audio source]
    end
  end
end
