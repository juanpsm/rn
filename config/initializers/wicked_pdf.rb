# WickedPDF Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# models by passing arguments to the `render :pdf` call.
#
# To learn more, check out the README:
#
# https://github.com/mileszs/wicked_pdf/blob/master/README.md

# La gema wkhtmltopdf-binary elige qué binario ejecutar leyendo
# /etc/os-release, y mapea cualquier ID que empiece con "pop", "zorin" o
# "elementary" a Ubuntu 18.04 sin mirar la versión:
#
#     os = 'ubuntu_18.04' if ... os.start_with?('pop') ...
#
# En un Pop!_OS 22.04 eso entrega un binario que enlaza OpenSSL 1.1 y falla con
# "error while loading shared libraries: libssl.so.1.1". Los runners de GitHub
# (ubuntu_24) sí caen en el binario correcto, por eso el CI no lo muestra.
#
# El wrapper de la gema respeta WKHTMLTOPDF_HOST_SUFFIX, así que alcanza con
# corregir el sufijo acá: se sigue usando el binario que la gema ya trae, sin
# extraer nada a mano ni pedirle configuración a quien clona el repo.
module WkhtmltopdfHostSuffix
  # Distros con numeración de versión de Ubuntu que la gema fija en 18.04.
  MISDETECTED = %w[pop zorin].freeze
  # Sufijos que la gema incluye, de mayor a menor.
  AVAILABLE = %w[22.04 20.04 18.04].freeze

  # `release` y `arch` se reciben como argumentos para poder testear la lógica
  # sin depender de la máquina donde corre la suite.
  def self.correction(release: read_os_release, arch: host_arch)
    id = release[/^ID=\"?([^\"\n]+)/, 1]
    version = release[/^VERSION_ID=\"?([^\"\n]+)/, 1]
    return unless id && version && MISDETECTED.include?(id)

    target = AVAILABLE.find { |v| Gem::Version.new(version) >= Gem::Version.new(v) }
    return if target.nil? || target == "18.04"

    "ubuntu_#{target}_#{arch}"
  end

  def self.read_os_release
    File.readable?("/etc/os-release") ? File.read("/etc/os-release") : ""
  end

  def self.host_arch
    RbConfig::CONFIG["host_cpu"] == "x86_64" ? "amd64" : "arm64"
  end

  # El binario tiene que existir realmente en la gema instalada; si no, es
  # preferible dejar que la gema elija y falle de forma conocida.
  def self.bundled?(suffix)
    dir = Gem.loaded_specs["wkhtmltopdf-binary"]&.gem_dir
    dir.present? && File.exist?(File.join(dir, "bin", "wkhtmltopdf_#{suffix}.gz"))
  end
end

if ENV["WKHTMLTOPDF_HOST_SUFFIX"].blank?
  suffix = WkhtmltopdfHostSuffix.correction
  if suffix && WkhtmltopdfHostSuffix.bundled?(suffix)
    ENV["WKHTMLTOPDF_HOST_SUFFIX"] = suffix
    Rails.logger&.info("wkhtmltopdf: se corrige el binario a #{suffix} (la gema detecta mal esta distribución)")
  end
end

WickedPdf.configure do |config|
  # Escotilla de escape por si hace falta un binario propio, por ejemplo uno
  # instalado por el sistema:
  #   export WKHTMLTOPDF_PATH=/usr/local/bin/wkhtmltopdf
  if ENV["WKHTMLTOPDF_PATH"].present?
    config.exe_path = ENV["WKHTMLTOPDF_PATH"]
  end

  # Layout file to be used for all PDFs
  # (but can be overridden in `render :pdf` calls)
  # config.layout = 'pdf.html'

  # Using wkhtmltopdf without an X server can be achieved by enabling the
  # 'use_xvfb' flag. This will wrap all wkhtmltopdf commands around the
  # 'xvfb-run' command, in order to simulate an X server.
  #
  # config.use_xvfb = true
end
