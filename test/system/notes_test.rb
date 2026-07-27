require "application_system_test_case"

class NotesTest < ApplicationSystemTestCase
  setup do
    @note = notes(:one)
    sign_in @note.book.user
  end

  test "visiting the index" do
    visit notes_url

    assert_selector "h1", text: "Notes"
    assert_text @note.title
  end

  test "creating a Note" do
    visit notes_url
    # El botón de alta es un link con ícono cuyo texto visible es "add".
    click_on "add"

    assert_selector "h1", text: "New Note"
    fill_in "Title", with: "Nota nueva"
    select @note.book.name, from: "Book"
    click_on "Create Note"

    assert_text "Note was successfully created"
    assert_selector "h1", text: "Nota nueva"
  end

  test "updating a Note" do
    visit note_url(@note)
    # Los botones de `show` son íconos sin texto, y el tooltip de Bootstrap les
    # saca el `title` al inicializarse, así que se los ubica por su href.
    find("a[href='#{edit_note_path(@note)}']").click

    fill_in "Title", with: "Título actualizado"
    click_on "Update Note"

    assert_text "Note was successfully updated"
    assert_selector "h1", text: "Título actualizado"
  end

  test "destroying a Note" do
    visit notes_url

    within first(".card-tools") do
      # "Destroy" vive dentro de un dropdown de AdminLTE: hay que abrirlo.
      find(".dropdown-toggle").click
      accept_confirm { click_on "Destroy" }
    end

    assert_text "Note was successfully destroyed"
    assert_no_text @note.title
  end
end
