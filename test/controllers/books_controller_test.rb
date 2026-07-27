require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @book = books(:one)
    sign_in @book.user
  end

  test "should get index" do
    get books_url
    assert_response :success
  end

  test "should get new" do
    get new_book_url
    assert_response :success
  end

  test "should create book" do
    assert_difference('Book.count') do
      # El nombre debe ser distinto al de @book: Book valida unicidad por usuario.
      post books_url, params: { book: { is_default: @book.is_default, name: 'Another book', user_id: @book.user_id } }
    end

    assert_redirected_to book_url(Book.last)
  end

  test "should show book" do
    get book_url(@book)
    assert_response :success
  end

  test "should get edit" do
    get edit_book_url(@book)
    assert_response :success
  end

  # Regresión: el botón de borrar apuntaba a `note_path` (sin argumento), que
  # tomaba el :id del request y armaba /notes/:id, así que borraba una nota en
  # vez del libro.
  test "show links the delete button to the book, not to a note" do
    get book_url(@book)

    destroy_links = css_select("a[data-method='delete']").map { |a| a["href"] }
    assert_includes destroy_links, book_path(@book)
  end

  test "should update book" do
    patch book_url(@book), params: { book: { is_default: @book.is_default, name: @book.name, user_id: @book.user_id } }
    assert_redirected_to book_url(@book)
  end

  test "should destroy book" do
    assert_difference('Book.count', -1) do
      delete book_url(@book)
    end

    assert_redirected_to books_url
  end
end
