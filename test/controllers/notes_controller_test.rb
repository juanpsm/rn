require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @note = notes(:one)
    sign_in @note.book.user
  end

  test "should get index" do
    get notes_url
    assert_response :success
  end

  test "should get new" do
    get new_note_url
    assert_response :success
  end

  test "should create note" do
    assert_difference('Note.count') do
      # El título debe ser distinto al de @note: Note valida unicidad por libro.
      post notes_url, params: { note: { book_id: @note.book_id, title: 'Another note' } }
    end

    assert_redirected_to note_url(Note.last)
  end

  test "should show note" do
    get note_url(@note)
    assert_response :success
  end

  test "should get edit" do
    get edit_note_url(@note)
    assert_response :success
  end

  test "should update note" do
    patch note_url(@note), params: { note: { book_id: @note.book_id, title: @note.title } }
    assert_redirected_to note_url(@note)
  end

  test "should destroy note" do
    assert_difference('Note.count', -1) do
      delete note_url(@note)
    end

    assert_redirected_to notes_url
  end

  # Regresión: las descargas de PDF pasaban `layout: "pdf.html"`. Rails 6.1
  # toleraba el sufijo de formato, pero desde Rails 7 la búsqueda es estricta y
  # fallaba con "Missing template layouts/pdf.html", devolviendo un 500.
  #
  # No se exige un 200: en máquinas donde wkhtmltopdf no puede ejecutarse la
  # acción redirige con un aviso, y eso también es correcto. Lo que se verifica
  # es que no explote, que es lo que rompía.
  %w[/notes_download].each do |path|
    test "#{path} renders without a template error" do
      get path

      assert_not_equal 500, response.status,
                       "la descarga falló: #{response.body[0, 300]}"

      if response.status == 200
        assert_equal "application/pdf", response.media_type
        assert response.body.start_with?("%PDF"), "el cuerpo no es un PDF"
      else
        assert_redirected_to notes_path
      end
    end
  end

  test "downloading a single note as PDF renders without a template error" do
    get note_download_url(@note)

    assert_not_equal 500, response.status, response.body[0, 300]
  end
end
