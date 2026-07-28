require "application_system_test_case"

class ProfilePhotoTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "reaching the account page from the sidebar" do
    visit root_url
    find(".sidebar-wrapper a[href='#{edit_user_registration_path}']").click

    assert_selector "h1", text: "My account"
  end

  test "the avatar falls back to the email initial" do
    visit edit_user_registration_url

    assert_selector ".user-initial", text: "O"
  end

  test "uploading a photo goes through the cropper" do
    visit edit_user_registration_url
    attach_file "user_avatar", file_fixture("avatar.png").to_s, make_visible: true

    # El modal de recorte se abre solo al elegir el archivo.
    assert_selector "#avatar-cropper.show", wait: 5
    within "#avatar-cropper" do
      assert_selector ".cropper-container"
      click_on "Use this crop"
    end
    assert_no_selector "#avatar-cropper.show"

    click_on "Save photo"

    assert_text "Profile photo updated"
    assert_predicate @user.reload.avatar, :attached?
    assert_selector "img.user-avatar"
  end

  test "cancelling the cropper clears the chosen file" do
    visit edit_user_registration_url
    attach_file "user_avatar", file_fixture("avatar.png").to_s, make_visible: true

    # Hay que esperar a que el modal termine de abrirse: durante la transición
    # Bootstrap ignora el hide(). `.cropper-container` sólo aparece cuando
    # Cropper.js ya se inicializó, o sea después de `shown.bs.modal`.
    assert_selector "#avatar-cropper.show .cropper-container", wait: 5
    within("#avatar-cropper") { click_on "Cancel" }
    assert_no_selector "#avatar-cropper.show"

    click_on "Save photo"

    assert_not_predicate @user.reload.avatar, :attached?
  end

  test "opting into Gravatar" do
    visit edit_user_registration_url
    check "Use my Gravatar when I have no photo uploaded"
    click_on "Save photo"

    assert_text "Profile photo updated"
    assert_predicate @user.reload, :use_gravatar?
  end
end
