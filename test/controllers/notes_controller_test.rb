require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @note = notes(:one)
    @user = @note.book.user
    sign_in @user
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

      # El cuerpo se interpola sólo si no es un PDF: el binario viene en
      # ASCII-8BIT y mezclarlo con un mensaje UTF-8 revienta.
      assert_not_equal 500, response.status, -> { "la descarga falló: #{response.body[0, 300]}" }

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

    assert_not_equal 500, response.status, -> { response.body[0, 300] }
  end

  # Regresión: la acción hacía un `send_data` por nota dentro de un bucle y
  # fallaba con DoubleRenderError, porque una request HTTP devuelve una sola
  # respuesta. Ahora los PDFs van dentro de un ZIP.
  test "downloading notes separately returns a zip with one entry per note" do
    get notes_download_separately_url

    assert_not_equal 500, response.status, -> { response.body[0, 300] }
    skip "wkhtmltopdf no disponible en esta máquina" unless response.status == 200

    assert_equal "application/zip", response.media_type

    entries = []
    Zip::File.open_buffer(StringIO.new(response.body)) { |zip| zip.each { |e| entries << e.name } }

    assert_equal @user.notes.count, entries.size
    assert entries.all? { |n| n.end_with?(".pdf") }, entries.inspect
  end

  test "downloading notes separately warns when there is nothing to export" do
    # `User#notes` es un has_many :through, no se puede modificar directamente.
    Note.where(book: @user.books).destroy_all

    get notes_download_separately_url

    assert_redirected_to notes_path
    assert_match(/any notes/, flash[:alert])
  end
end
