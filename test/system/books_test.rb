require "application_system_test_case"

class BooksTest < ApplicationSystemTestCase
  setup do
    @book = books(:one)
    sign_in @book.user
  end

  test "visiting the index" do
    visit books_url

    assert_selector "h1", text: "Books"
    assert_text @book.name
  end

  test "creating a Book" do
    visit books_url
    # El botón de alta es un link con ícono cuyo texto visible es "add".
    click_on "add"

    assert_selector "h1", text: "New Book"
    fill_in "Name", with: "Cuaderno de viaje"
    click_on "Create Book"

    assert_text "Book was successfully created"
    assert_selector "h1", text: "Cuaderno de viaje"

    # Ya no hay botón "Back": la navegación de vuelta son las migas de pan.
    within(".breadcrumb") { click_on "books" }
    assert_selector "h1", text: "Books"
  end

  test "updating a Book" do
    visit book_url(@book)
    # Los botones de `show` son íconos sin texto, y el tooltip de Bootstrap les
    # saca el `title` al inicializarse, así que se los ubica por su href.
    find("a[href='#{edit_book_path(@book)}']").click

    fill_in "Name", with: "Nombre actualizado"
    click_on "Update Book"

    assert_text "Book was successfully updated"
    assert_selector "h1", text: "Nombre actualizado"
  end

  # Recuperado del PR #74, que arregló este mismo bug el 27/07: el botón usaba
  # `note_path` sin argumento y el helper completaba el :id con el del request,
  # así que desde /books/42 mandaba un DELETE a /notes/42.
  #
  # Ese test se perdió en la migración a AdminLTE 4 (785ffda), que reescribió
  # books/show.html.erb desde la versión previa al arreglo y reintrodujo el
  # bug. Sin el test, nadie lo notó hasta dos días después.
  #
  # El de controlador comprueba el href renderizado; éste hace el click y
  # verifica que el libro efectivamente desaparezca.
  test "destroying a Book from its show page" do
    visit book_url(@book)

    accept_confirm { find("a[aria-label='Delete book']").click }

    assert_text "Book was successfully destroyed"
    assert_selector "h1", text: "Books"
    assert_nil Book.find_by(id: @book.id)
  end

  test "destroying a Book" do
    visit books_url

    within first("tbody tr") do
      # Las acciones ya no viven en un dropdown de texto: son botones de ícono
      # con el nombre de la acción en aria-label (el tooltip de Bootstrap les
      # saca el `title` al inicializarse).
      accept_confirm { find("a[aria-label='Delete book']").click }
    end

    assert_text "Book was successfully destroyed"
    assert_no_text @book.name
  end
end
