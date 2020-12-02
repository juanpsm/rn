module RN
  module RougeeHelper
    require 'redcarpet'
    require 'rouge'
    require 'rouge/plugins/redcarpet'

    class HTML < Redcarpet::Render::HTML
      include Rouge::Plugins::Redcarpet
    end

    def self.rouge_markdown(text)
      render_options = {
          filter_html: true,
          hard_wrap: true,
          link_attributes: { rel: 'nofollow' }
      }
      renderer = HTML.new(render_options)

      extensions = {
          autolink: true,
          fenced_code_blocks: true,
          lax_spacing: true,
          no_intra_emphasis: true,
          strikethrough: true,
          superscript: true
      }

      markdown = Redcarpet::Markdown.new(renderer, extensions)
      markdown.render(text)
    end
  end
end