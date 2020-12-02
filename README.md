# rn

Proyecto para el Trabajo Práctico Integrador de la cursada 2020 de la materia
Taller de Tecnologías de Producción de Software - Opción Ruby, de la Facultad de Informática de la Universidad Nacional de La Plata.

Ruby Notes, o simplemente `rn`, es un gestor de notas concebido como un clon simplificado
de la excelente herramienta [TomBoy](https://wiki.gnome.org/Apps/Tomboy).

## Uso de `rn`

Para ejecutar el comando principal de la herramienta se utiliza el script `bin/rn`, el cual
puede correrse de las siguientes manera:

```bash
$ ruby bin/rn [args]
```

O bien:

```bash
$ bundle exec bin/rn [args]
```

O simplemente:

```bash
$ bin/rn [args]
```

Si se agrega el directorio `bin/` del proyecto a la variable de ambiente `PATH` de la shell,
el comando puede utilizarse sin prefijar `bin/`:

```bash
# Esto debe ejecutarse estando ubicad@ en el directorio raiz del proyecto, una única vez
# por sesión de la shell
$ export PATH="$(pwd)/bin:$PATH"
$ rn [args]
```


## Desarrollo

### Instalación de dependencias

```bash
$ bundle install
```

> Nota: Bundler debería estar disponible en tu instalación de Ruby, pero si por algún
> motivo al intentar ejecutar el comando `bundle` obtenés un error indicando que no se
> encuentra el comando, podés instalarlo mediante el siguiente comando:
>
> ```bash
> $ gem install bundler
> ```

Una vez que la instalación de las dependencias sea exitosa (esto deberías hacerlo solamente
cuando estés comenzando con la utilización del proyecto), podés comenzar a probar la
herramienta y a desarrollar tu entrega.

### Estructura de la plantilla

* `lib/`: directorio que contiene todas las clases del modelo y de soporte para la ejecución
  del programa `bin/rn`.
  * `lib/rn.rb` es la declaración del namespace `RN`, y las directivas de carga de clases
    o módulos que estén contenidos directamente por éste (`autoload`).
  * `lib/rn/` es el directorio que representa el namespace `RN`. Notá la convención de que
    el uso de un módulo como namespace se refleja en la estructura de archivos del proyecto
    como un directorio con el mismo nombre que el archivo `.rb` que define el módulo, pero
    sin la terminación `.rb`. Dentro de este directorio se ubicarán los elementos del
    proyecto que estén bajo el namespace `RN` - que, también por convención y para facilitar
    la organización, deberían ser todos. Es en este directorio donde deberías ubicar tus
    clases de modelo, módulos, clases de soporte, etc. Tené en cuenta que para que todo
    funcione correctamente, seguramente debas agregar nuevas directivas de carga en la
    definición del namespace `RN` (o dónde corresponda, según tus decisiones de diseño).
  * `lib/rn/commands.rb` y `lib/rn/commands/*.rb` son las definiciones de comandos de
    `dry-cli` que se utilizarán. En estos archivos es donde comenzarás a realizar la
    implementación de las operaciones en sí, que en esta plantilla están provistas como
    simples disparadores.
  * `lib/rn/version.rb` define la versión de la herramienta, utilizando [SemVer](https://semver.org/lang/es/).
* `bin/`: directorio donde reside cualquier archivo ejecutable, siendo el más notorio `rn`
  que se utiliza como punto de entrada para el uso de la herramienta.

  ### Notas de desarrollo Entrega 1

  * Armado de ejemplos en las mismas llamadas a los comandos
  * https://stackoverflow.com/questions/36350321/errnoenoent-no-such-file-or-directory-rb-sysopen
  * Editor de notas "a mano"
    ```ruby
    prompt = "RN>> "
    eof = "EON"
    eof_feedback = " [End Of Note]\n"
    File.open(file, File::RDWR|File::CREAT, 0644) {|f|
      f.flock(File::LOCK_EX)
      f.rewind
      print "\nWrite the contents of the note below.\nYou can write multiple lines.\nEnd the note with '#{eof}' + [Enter].\n\n#{prompt}"
      content = ""
      input_line = STDIN.gets
        while input_line.chomp != eof
          content << input_line
          print "#{prompt}"
          input_line = STDIN.gets
        end
      print eof_feedback
      f.write content
      f.truncate(f.pos)
    }
    ```
  * (Quizás) ~~Agregar [logger](https://github.com/piotrmurach/tty-logger), [colores](), [prompt](https://github.com/piotrmurach/tty-prompt), [font?](https://github.com/piotrmurach/tty-font), [box](https://github.com/piotrmurach/tty-box)~~

  * [x] Separar Modelo de Comandos 
  *  [x] Separar manejo de archivos de Modelo

### Notas de desarrollo Entrega 2
  * Elegir formato de texto plano:
    + [x] [Markdown](https://daringfireball.net/projects/markdown/syntax)
    + [ ] [reStructuredText](https://docutils.sourceforge.io/docs/user/rst/quickref.html)
    + [ ] [MediaWiki](https://www.mediawiki.org/wiki/MediaWiki_Language_Extension_Bundle)
  * Elegir formato rico:
    + [x] HTML
    + [ ] PDF
  * Para convertir de texto Markdown a HTML estuve probando dos liberias [redcarpet](https://github.com/vmg/redcarpet) y [github-markdown](https://github.com/github/markup). El problema que tenia este último es que necesita que llos archivos sean `.markdown` y tuve que hacer archivos temporales porque no queria modificar demasiado como se guardaban los archivos desde antes. Entonces a la hora de exportar un archivo se hace una copia a a una carpeta temporal con la estensión correspondiente para que pueda leerlo ese modulo. No me gustaba esta estrategia por eso termine decidiendome a último momento por **redcarpet** que además tiene mejor documentación y me fué mas sencillo de configurar.
  * Un problema que tuve para agregar el comando `--export` fue que no sabía si ponerlo en la parte de notas, o en la parte de libros (`n` y `b` son los argumentos principales). El un principio pense ponerlo del lado de libro y que se use de la siguiente manera:
    ```bash
    rn b export --note unaNota --book unLibro  # para exportar las notas "unaNota" de "unLibro"
    rn b export --global                       # para exportar las notas globales
    rn b export --book unLibro                 # para exportar las notas de unLibro
    rn b export                                # para exportar todas las notas
    ```
    El problema era que se usaba `--book` para indicar el libro con la intención de exporar todas las notas de ese libro se podia pisar con cuando se usa esa misma opción para indicar el libro al que perteneces una nota. Por ello decidi ponerlo bajo el comando de notas (aunque pensandolo ahora podría accederse de ambos "lados").
    Asi:
    ```bash
    rn n export unaNota --book unLibro  # para exportar las notas "unaNota" de "unLibro"
    rn n export --global                       # para exportar las notas globales
    rn n export --book unLibro                 # para exportar las notas de unLibro
    rn n export                                # para exportar todas las notas
    ```
    Por lo tanto cuando el argumento de la nota es nulo, se toma que se exportaran todas las notas de el libro indicado por la opción `--book`.
    De todas maneras las notas no conoces a los libros y a las otras notas, por lo que el manejo interno igualmente lo hace la clase `Book`, que arma las colecciones pertinentes de notas, pidiendole los datos a la clase `Note`, para luego llamar a la nueva clase `Exporter` que con ayuda de la clase `FileManager` mueve y crea los nuevos archivos.
  * Se ofrecen algunas opciones para facilitar el uso, aunque esto fue pensado con el optimismo de tener varios sistemas de marcado y varios formatos de salida, pero ya queda el cli por si en algún momento se imprementa. Para ello uso [TTY-prompt](https://github.com/piotrmurach/tty-prompt)

  * Al HTML que genera *redcarpet* se le agregan unos simples tags para indicar el título y libro de la nota. Se intento embellecerlos con unas librerías sin éxito ([codeprettify](https://github.com/googlearchive/code-prettify#readme) parece que ya no anda mas, y [rouge](https://github.com/rouge-ruby/) ([tutorial](https://www.tom-meehan.com/posts/how-i-get-this-awesome-syntax-highlighting-using-redcarpet-and-rouge)) parece que hay que usarlo con *rails*, asi que para más adelante).
  * Para intentar la conversión a PDF se estuvo leyendo [esto](https://github.com/walle/gimli), [esto](http://www.rubyinside.com/prawn-ruby-pdf-library-987.html) y [esto](https://wkhtmltopdf.org/)