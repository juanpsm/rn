require "test_helper"

class ProfilePhotosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "uploads a photo" do
    assert_changes -> { @user.reload.avatar.attached? }, from: false, to: true do
      patch profile_photo_url, params: { user: { avatar: uploaded_avatar } }
    end

    assert_redirected_to edit_user_registration_path
  end

  test "removes the current photo" do
    patch profile_photo_url, params: { user: { avatar: uploaded_avatar } }
    assert_predicate @user.reload.avatar, :attached?

    patch profile_photo_url, params: { user: { remove_avatar: "1" } }

    assert_not_predicate @user.reload.avatar, :attached?
  end

  test "toggles the Gravatar preference" do
    patch profile_photo_url, params: { user: { use_gravatar: "1" } }
    assert_predicate @user.reload, :use_gravatar?

    patch profile_photo_url, params: { user: { use_gravatar: "0" } }
    assert_not_predicate @user.reload, :use_gravatar?
  end

  test "rejects a file that is not an image and keeps the previous state" do
    patch profile_photo_url, params: {
      user: { avatar: fixture_file_upload("not_an_image.txt", "text/plain") }
    }

    assert_not_predicate @user.reload.avatar, :attached?
    assert_match(/JPEG/, flash[:alert])
  end

  # No pide la contraseña actual: ése es justamente el motivo de tener un
  # controlador aparte del de Devise.
  test "does not require the current password" do
    patch profile_photo_url, params: { user: { avatar: uploaded_avatar } }

    assert_redirected_to edit_user_registration_path
    assert_predicate @user.reload.avatar, :attached?
  end

  test "requires an authenticated user" do
    sign_out @user

    patch profile_photo_url, params: { user: { use_gravatar: "1" } }

    assert_redirected_to new_user_session_path
  end

  private

  def uploaded_avatar
    fixture_file_upload("avatar.png", "image/png")
  end
end
