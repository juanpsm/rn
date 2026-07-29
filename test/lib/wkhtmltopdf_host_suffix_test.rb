require "test_helper"

# La gema wkhtmltopdf-binary mapea "pop" y "zorin" a Ubuntu 18.04 sin mirar la
# versión, y ese binario enlaza OpenSSL 1.1. El inicializador corrige el sufijo
# para las distribuciones afectadas.
class WkhtmltopdfHostSuffixTest < ActiveSupport::TestCase
  def release(id:, version:)
    %(NAME="Test"\nID=#{id}\nID_LIKE="ubuntu debian"\nVERSION_ID="#{version}"\n)
  end

  test "corrige Pop!_OS 22.04, que la gema fija en 18.04" do
    suffix = WkhtmltopdfHostSuffix.correction(
      release: release(id: "pop", version: "22.04"), arch: "amd64"
    )

    assert_equal "ubuntu_22.04_amd64", suffix
  end

  test "usa el binario de 20.04 en versiones intermedias" do
    suffix = WkhtmltopdfHostSuffix.correction(
      release: release(id: "pop", version: "20.04"), arch: "amd64"
    )

    assert_equal "ubuntu_20.04_amd64", suffix
  end

  test "respeta la arquitectura" do
    suffix = WkhtmltopdfHostSuffix.correction(
      release: release(id: "pop", version: "22.04"), arch: "arm64"
    )

    assert_equal "ubuntu_22.04_arm64", suffix
  end

  test "no corrige cuando la versión sí corresponde a 18.04" do
    assert_nil WkhtmltopdfHostSuffix.correction(
      release: release(id: "pop", version: "18.04"), arch: "amd64"
    )
  end

  test "no toca las distribuciones que la gema detecta bien" do
    %w[ubuntu debian fedora].each do |id|
      assert_nil WkhtmltopdfHostSuffix.correction(
        release: release(id: id, version: "22.04"), arch: "amd64"
      ), "no debería corregir #{id}"
    end
  end

  test "no falla si /etc/os-release no tiene los campos esperados" do
    assert_nil WkhtmltopdfHostSuffix.correction(release: "", arch: "amd64")
    assert_nil WkhtmltopdfHostSuffix.correction(release: "ID=pop\n", arch: "amd64")
  end

  test "el binario que propone viene incluido en la gema" do
    suffix = WkhtmltopdfHostSuffix.correction(
      release: release(id: "pop", version: "22.04"), arch: "amd64"
    )

    assert WkhtmltopdfHostSuffix.bundled?(suffix),
           "la gema debería traer wkhtmltopdf_#{suffix}.gz"
  end
end
