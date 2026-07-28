require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup { @user = users(:one) }

  test "avatar_source falls back to the email initial" do
    assert_equal :initial, @user.avatar_source
    assert_equal "O", @user.avatar_initial
  end

  test "avatar_source prefers Gravatar when the user opted in" do
    @user.update!(use_gravatar: true)
    assert_equal :gravatar, @user.avatar_source
  end

  test "avatar_source prefers an uploaded photo over Gravatar" do
    @user.update!(use_gravatar: true)
    attach_avatar
    assert_equal :upload, @user.avatar_source
  end

  test "gravatar_url hashes the normalised email with SHA256" do
    @user.update!(email: "  ONE@Example.com  ")
    expected = Digest::SHA256.hexdigest("one@example.com")

    assert_includes @user.gravatar_url, expected
    assert_includes @user.gravatar_url(size: 120), "s=120"
  end

  test "accepts a valid image" do
    attach_avatar
    assert_predicate @user, :valid?
  end

  test "rejects a file that is not an accepted image" do
    @user.avatar.attach(
      io: File.open(Rails.root.join("test/fixtures/files/not_an_image.txt")),
      filename: "not_an_image.txt",
      content_type: "text/plain"
    )

    assert_not_predicate @user, :valid?
    assert_includes @user.errors[:avatar].to_sentence, "JPEG"
  end

  # El chequeo importante: el tipo se decide por los bytes, no por lo que
  # declara quien sube el archivo. ActiveStorage guarda la declaración del
  # cliente, así que validar `avatar.content_type` dejaba pasar esto.
  test "rejects a file that only claims to be an image" do
    @user.avatar.attach(
      io: File.open(Rails.root.join("test/fixtures/files/disguised.png")),
      filename: "disguised.png",
      content_type: "image/png"
    )

    assert_equal "image/png", @user.avatar.content_type, "ActiveStorage confía en el tipo declarado"
    assert_not_predicate @user, :valid?
    assert_includes @user.errors[:avatar].to_sentence, "JPEG"
  end

  test "rejects an image over the size limit" do
    attach_avatar
    # Se falsea el tamaño en el blob para no versionar un archivo de 2 MB.
    @user.avatar.blob.update!(byte_size: User::AVATAR_MAX_SIZE + 1)

    assert_not_predicate @user, :valid?
    assert_includes @user.errors[:avatar].to_sentence, "smaller than 2 MB"
  end

  private

  def attach_avatar
    @user.avatar.attach(
      io: File.open(Rails.root.join("test/fixtures/files/avatar.png")),
      filename: "avatar.png",
      content_type: "image/png"
    )
  end
end
