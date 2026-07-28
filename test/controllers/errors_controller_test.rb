require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "should get not_found" do
    get my_not_found_url
    assert_response :not_found
    assert_select "h1", text: "404"
    assert_select "h2", text: "The page you were looking for doesn't exist."
  end

  test "should get unprocessable_entity" do
    get my_unprocessable_entity_url
    assert_response :unprocessable_entity
    assert_select "h1", text: "422"
  end

  test "should get internal_server_error" do
    get my_internal_server_error_url
    assert_response :internal_server_error
    assert_select "h1", text: "500"
  end

  # Las excepciones también salen de peticiones que no son HTML: la miniatura
  # de un avatar, un PDF, un fetch. Antes, para esos formatos, no había
  # plantilla y fallaba el render de la propia página de error:
  #   "Error during failsafe response: Missing template ... {:formats=>[:png]}"
  test "responds to non-HTML requests without blowing up" do
    get my_internal_server_error_url(format: :png)
    assert_response :internal_server_error
    assert_empty response.body

    get my_not_found_url(format: :pdf)
    assert_response :not_found
  end

  test "responds to JSON requests with a JSON body" do
    get my_not_found_url(format: :json)

    assert_response :not_found
    assert_equal "not_found", response.parsed_body["error"]
  end

  # Nota: no se testea acá el ruteo de una URL inexistente porque en el entorno
  # de test `consider_all_requests_local` es true y DebugExceptions muestra su
  # propia página antes de delegar en `exceptions_app`. En producción, con
  # `consider_all_requests_local = false`, la excepción sí llega a estas rutas.
end
