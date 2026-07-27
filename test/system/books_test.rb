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

    click_on "Back"
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

  test "destroying a Book from its show page" do
    visit book_url(@book)

    accept_confirm { find("a[href='#{book_path(@book)}'][data-method='delete']").click }

    assert_text "Book was successfully destroyed"
    assert_selector "h1", text: "Books"
    assert_nil Book.find_by(id: @book.id)
  end

  test "destroying a Book" do
    visit books_url

    within first("tbody tr") do
      # "Destroy" vive dentro de un dropdown de AdminLTE: hay que abrirlo.
      find(".dropdown-toggle").click
      accept_confirm { click_on "Destroy" }
    end

    assert_text "Book was successfully destroyed"
    assert_no_text @book.name
  end
end
