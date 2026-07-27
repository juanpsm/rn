require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "should get not_found" do
    get my_not_found_url
    assert_response :not_found
    assert_select "h1", text: "The page you were looking for doesn't exist."
  end

  test "should get unprocessable_entity" do
    get my_unprocessable_entity_url
    assert_response :unprocessable_entity
  end

  test "should get internal_server_error" do
    get my_internal_server_error_url
    assert_response :internal_server_error
  end

  # Nota: no se testea acá el ruteo de una URL inexistente porque en el entorno
  # de test `consider_all_requests_local` es true y DebugExceptions muestra su
  # propia página antes de delegar en `exceptions_app`. En producción, con
  # `consider_all_requests_local = false`, la excepción sí llega a estas rutas.
end
