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

  # Regresión: la vista usaba `note_path` sin argumento. Los helpers de ruta
  # completan el `:id` que falta con el de la request en curso, así que en vez
  # de fallar generaban `/notes/<id-del-libro>` y el botón "Delete book"
  # apuntaba a borrar una nota.
  test "the delete action on a book points at the book" do
    get book_url(@book)

    assert_select %(a[aria-label="Delete book"]) do |links|
      assert_equal 1, links.size
      assert_equal book_path(@book), links.first["href"]
      assert_equal "delete", links.first["data-method"]
    end
  end

  test "every book action resolves to an explicit id" do
    get book_url(@book)

    assert_select %(a[aria-label="Edit book"][href=?]), edit_book_path(@book)
    assert_select %(a[href=?]), download_all_notes_from_book_path(@book)
  end
end
