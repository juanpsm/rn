class ErrorsController < ApplicationController
  def not_found
    render_error :not_found
  end

  def unprocessable_entity
    render_error :unprocessable_entity
  end

  def internal_server_error
    render_error :internal_server_error
  end

  private

  # Las excepciones no siempre vienen de una petición HTML: también fallan
  # pedidos de imágenes, PDFs o JSON. Antes se hacía `render` a secas, así que
  # ante un error en, por ejemplo, la miniatura de un avatar, Rails buscaba
  # `errors/internal_server_error.png`, no lo encontraba y la propia página de
  # error explotaba:
  #
  #   Error during failsafe response: Missing template
  #   errors/internal_server_error with {:formats=>[:png]}
  #
  # Para formatos sin plantilla se devuelve el estado pelado, que es lo que un
  # <img> o un fetch pueden manejar.
  def render_error(status)
    respond_to do |format|
      format.html { render status: status }
      format.json { render json: { error: status.to_s }, status: status }
      format.any { head status }
    end
  end
end
