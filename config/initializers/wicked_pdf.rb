# WickedPDF Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# models by passing arguments to the `render :pdf` call.
#
# To learn more, check out the README:
#
# https://github.com/mileszs/wicked_pdf/blob/master/README.md

WickedPdf.configure do |config|
  # Path to the wkhtmltopdf executable: This usually isn't needed if using
  # one of the wkhtmltopdf-binary family of gems.
  #
  # Escotilla de escape para distribuciones que la gema wkhtmltopdf-binary
  # detecta mal. Su wrapper elige el binario leyendo /etc/os-release, y mapea
  # cualquier ID que empiece con "pop" a Ubuntu 18.04 sin mirar la versión:
  #
  #     os = 'ubuntu_18.04' if ... os.start_with?('pop') ...
  #
  # En Pop!_OS 22.04 eso entrega un binario que enlaza libssl 1.1, y como el
  # sistema trae OpenSSL 3 falla con "error while loading shared libraries".
  # Los runners de GitHub (ubuntu_24) sí caen en el binario correcto.
  #
  # Para usar otro binario:
  #   gunzip -c "$(bundle show wkhtmltopdf-binary)/bin/wkhtmltopdf_ubuntu_22.04_amd64.gz" > ~/.local/bin/wkhtmltopdf
  #   chmod +x ~/.local/bin/wkhtmltopdf
  #   export WKHTMLTOPDF_PATH=~/.local/bin/wkhtmltopdf
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
