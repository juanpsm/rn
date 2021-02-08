# rn

Proyecto para el Trabajo Práctico Integrador de la cursada 2020-2021 de la materia
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

  ### Notas de desarrollo Entrega 3

  Esta entrega consiste en portear la aplicación CLI a una aplicación web usando rails. Tambien se agregaran funcionalidades y modificaciones al modelo de datos como la incorporación de usuarios tendrán cierta relacion con las notas y libros ya existentes.
  Lo primero que hice fue familiarizarme un poco con el framework leyendo y haciendo algunos ejercicios:
  * [Guia de rails](https://guides.rubyonrails.org/getting_started.html)
  * [Tutorial de autentificacion](https://levelup.gitconnected.com/simple-authentication-guide-with-ruby-on-rails-16a6255f0be8)
  * Instale rails y todas las dependencias necesarias y hice casi todo el curso, hasta que llegue a la autenticación. Aquí empezaron los primeros problemas:
    ```bash
    LoadError: cannot load such file -- bcrypt
    ```
    Había un problema con esa gema que no se pudo solucionar con `gem install bcrypt --platform=ruby` como sugerían
  * Ya comenzando con el trabajo, sabia que necesitaría un editor de texto para editar las notas en la web. Viendo que el más recomendado era `ActionText` me dispuse a instalarlo.
  Para mi desgracia había un [bug](https://github.com/rails/rails/pull/41200) que no me permitia instalarlo:
    ```bash
    ruby bin\rails action_text:install
          rails  app:binstub:yarn
    Installing JavaScript dependencies
            run  bin/yarn add trix@^1.2.0 @rails/actiontext@^6.1.1 from "."
    rails aborted!
    Errno::ENOEXEC: Exec format error - bin/yarn add trix@^1.2.0 @rails/actiontext@^6.1.1

    Tasks: TOP => action_text:install
    ```
    El problema estaba relacionado con utilizar Windows, pero siendo verano y estando en la casa de mis padres, no tenia otra opción.
    Así que en una maquina virtual cloné el repositorio, instalé todas las dependencias y ahi surgio otro problema de permisos:
    ```bash
    rails  app:binstub:yarn
    Installing JavaScript dependencies
            run  bin/yarn add trix@^1.2.0 @rails/actiontext@^6.1.1 from "."
    rails aborted!
    Errno::EACCES: Permission denied - bin/yarn

    Tasks: TOP => action_text:install
    ```
    La [solución](https://github.com/yarnpkg/yarn/issues/1806#issuecomment-358143320) que primero se me ocurrió fue simplemente cambiar los permisos de todo el proyecto
    ```bash
    sudo chmod -R 777 path/to//project
    ```
    Pero no surtió efecto. [Leyendo](https://stackoverflow.com/questions/18433609/getting-usr-bin-env-ruby-exe-no-such-file-or-directory-on-heroku) un poco mas parecia que estan mal los binarios para linux al haberlos clonado de windows. Se arregla con 
    ```bash
    $ rake app:update:bin
    ```
    Y así `rails action_text:install` crea los archivos por fin.

  * Luego otro problema muy raro con unas credenciales que sinceramente no entendí
    ```bash
    ActiveSupport::MessageEncryptor::InvalidMessage
    ```
    Para arreglarlo hubo que setear  un editor de texto `set EDITOR="notepad.exe"` y `rails credentials:edit`
    Comentamos las lineas
    ```bash
    # aws:
    #   access_key_id: 123
    #   secret_access_key: 345

    # Used as the base secret for all 
    
    MessageVerifiers in Rails, including the one protecting cookies.
    secret_key_base: 

    89320682a93db53e46cb82a71ee0b8d0dbd9a18d90b1f90a7f377e7d216cfaf9255bc0415be85acb68343a4ea

    4680e08507812bdd7d040f03d032a8bf733801d
    ```
    Sigue pasando. borrar lineas comentadas de config/storage.yml
  * Un truco aprendido cuando se estan editando los estilos css, para no tener que hacer refresh todo el tiempo, además de correr el `rails server` se puede correr
    ```bash
    ruby .\bin\webpack-dev-server
    ```
    Entonces se actualiza al instante
  * Muchas veces paso que había que modificar alguna tabla para agregar algún atributo y se rompían las migraciones, no salía de "table already exists", entonces con `rails console` y luego
    ```bash
    ActiveRecord::Migration.drop_table(:users)
    ```
    Si eso no funcionaba había que borrar directamente los archivos `development.sql` y `test.sql` y volver a crear la bd
  * Para evitar estas idas y vueltas lo mejor fue que me ponga a pensar en mi modelo de datos:

  * Para la autenticacion y too el manejo de usuarios decidi usar la gema Devise. Para instalarla habia que correr `rails generate devise:install` y luego seguir unos pasos para instalarla
    ```bash
    1. Ensure you have defined default url options in your environments files. Here
        is an example of default_url_options appropriate for a development environment
        in config/environments/development.rb:

          config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

        In production, :host should be set to the actual host of your application.

        * Required for all applications. *

      2. Ensure you have defined root_url to *something* in your config/routes.rb.
        For example:

          root to: "home#index"

        * Not required for API-only Applications *

      3. Ensure you have flash messages in app/views/layouts/application.html.erb.
        For example:

          <p class="notice"><%= notice %></p>
          <p class="alert"><%= alert %></p>

        * Not required for API-only Applications *

      4. You can copy Devise views (for customization) to your app by running:

          rails g devise:views
    ```
    Esto último lo use para generar las vistas de Login y Register que luego modifique para que se adapten al diseño de mi aplicación.
  * Llego un momento que tenia que ver como cumplir con el requerimiento de que ek Libro por defecto de un usuario no se debe borrar. Primero pense que podría ser suficiente asegurarme que el usuario no se quede sin ningún Libro en ningun momento, pero luego releyendo la consigna, vi que el usuario no debe tener la capacidad de cambiar de libro por defecto. Asi que decidi pritmero que ni bien un usuario se registre debia crear este libro.
    Por eso:
    ```ruby
    class User < ApplicationRecord
      ...

      def create_default_notebook
        @user = User.last
        @book = @user.books.create(
                  name: "#{@user.email.split(/@/)[0]}'s notebook",
                    is_default: true)
        @user.default_book_id = @book.id
        @user.save
      end
    end
    ```
    Y luego me aseguro que la variable para cualquier otro libro que se cree sea siempre `false`
    ```ruby
    # POST /books or /books.json
    def create
      @book = current_user.books.create(book_params)
      @book.is_default = false
    ```
    Ademas protejo que no me puedan "mandar" el formulario trucado por otro lado con ese nombre, con los llamados *parámetros fuertes*:
    ```ruby
    # Only allow a list of trusted parameters through.
    def book_params
      params.require(:book).permit(:name)
    end
    ```
  * Para evitar que el usuario borre el directorio por defecto entonces lo que hago es tirar una excepcion cuando esto sucede, abortando así la destrucción del libro y sus notas. [Idea](https://stackoverflow.com/questions/39280408/rails-how-to-prevent-the-deletion-of-records)
  Primero se levanta un error si el libro que se intenta borrar tiene atributo `is_default`
    ```ruby
    class Book < ApplicationRecord
      ...
      after_destroy :ensure_default_book_remains

      class Error < StandardError
      end

      protected #or private whatever you need

          #Raise an error that you trap in your controller to prevent your record being deleted.
            def ensure_default_book_remains
              if is_default
              raise Error.new "Can't delete default book"
            end
          end
    end
    ```
    Este error se agarra en el controlador, para manejarlo, y poder informarle al usuario.
    ```bash
    # en books_controller.rb
    # DELETE /books/1 or /books/1.json
    def destroy
      @book.destroy
      respond_to do |format|
        format.html { redirect_to books_url, notice: "Book was successfully destroyed." }
        format.json { head :no_content }
      end
    end
    #Note, the rescue block is outside the destroy method
    rescue_from 'Book::Error' do |exception|
      redirect_to books_path, alert: exception.message
    end
    ```
  * Luego para darle un poco de estilo al proyecto integre [AdminLTE](https://dev.to/brayvasq/integrate-andminlte-with-ruby-on-rails-6-od7)
  * Intenté pensar si vaía la pena implementar un [borrado lógico](https://medium.com/galvanize/soft-deletion-is-actually-pretty-hard-cb434e24825c#:~:text=Any%20record%20where%20that%20column,with%20the%20time%20of%20deletion.)
    Pero terminé decidiendo que no, ya que para eso esta la funcionalidad de poder bajar los datos en pdf, y ademas se generan problemas con los borrados (y restauraciones) en cascada por culpa de las relaciones uno a muchos que se dan en el modelo. Como no está especificado en los requerimientos, decidi hacer un borrado en cascada. Es decir cuando se elimina un usuario, se eliminan todos sus libros, y a la vez cada ves libro que se elimine provocará que se eliminen todas las notas que a el pertenecen. Esto se encuentra debidamente advertido al usuario.
    ```bash
    class Book < ApplicationRecord
    has_many :notes, :dependent => :destroy
    ```
  * Para agregar la funcionalidad de bajar los pdf necesitaba una librería que interpretase el html del tenxto rico de las notas y generase un PDF, para eso use la gema [wkhtmltopdf](https://www.viget.com/articles/how-to-create-pdfs-in-rails/). Obviamente tuvo sus [problemas](https://github.com/mileszs/wicked_pdf/issues/693) pero finalemente funcionó.
  * Tambien modifique algunas cosas en el cuerpo del texto rico de las notas, para que pueda contener diversos tipos de [archivos](https://acuments.com/uploading-audio-video-pdf-with-action-text.html). Sin embargo no no logré que estos atributes se embeban en el pdf si bien se muestran correctamente en la web.
  * [Validaciones](https://guides.rubyonrails.org/active_record_validations.html) pude prescindir de algunas validaciones que tenia en la version anterior debido a que los nombres de las notas eran nombres de archivos físicos y por ende tenian muchas restricciones. Aqui lo unico que me interesaba es que no estén en blanco el nombre de los libros y el título. Tambien que no se repitan, aunque solo con alcance de cada usuario. Y ademas quiero que no diferencie entre mayúscula y minúsculal para estas comparaciones. Asi que el `:title` de las notas tiene unicidad con *scope* a `:book` y el `:name` de estos tiene unicidad con *scope* a `:user`. Este último ademas tiene un email que si es unico en todo el sistema, y debe ser un email valido, y su contraseña debe tener mas de 6 caracteres.
    ```bash
    class Book < ApplicationRecord
    ...
    validates :name, presence: true, uniqueness: { :case_sensitive => false, scope: :user,
      message: "of book already exists in your collection" }
    ```
  * Para el tema de los [permisos](https://stackoverflow.com/questions/7024111/how-do-i-prevent-access-to-records-that-belong-to-a-different-user/7024559) pense en utilizar una gema que se llama *CanCanCan*, pero decidi que era demasiado, ya que no tenia tantos permisos para setear. Simplemente un usuario no logueado solo puede loguearse o registrarse. Y luego me tengo que asegurar que solo pueda acceder a sus notas y libros sin nunca ver los otros.
  Para ello lo que hago es nunca buscar en los controladores cosas del estilo `@book = Book.all`, aprovecho la existencia de la variable `current_user` que tiene las colecciones y busco a partir de ellas.
    Por ejemplo una búsqueda, haciendola así seguro que no obtengo datos de otros usuarios, porque parto de esta colección acotada.
    ```bash
    @notes = current_user.notes
      if params[:search] && params[:search] != ""
        @notes =  @notes.joins(:action_text_rich_text)
              .where(...
    ```
    Pero puede ser que aunque yo no otorgue esos resultados directamente, puedan intentar acceder por la url a un dato que no les corresponda.
    Entonces otra forma de hacer llegar al mismo fin es restringiendo activamente el acceso a un dato que pertence a otro usuario. Por ejemplo `set_book` es una funcion que uso siempre antes de todas las acciones en el controlador de libros (con un `before_action`):
    ```bash
    def set_book
      @book = Book.find(params[:id])
      restrict_access if @book.user_id != current_user.id
    end

    def restrict_access
      redirect_to root_path, :alert => "Access denied"
    end
    ```
    En este casi si busco entre todos los libros del sistema, pero si no coincide el id con el usuario logueado, entonces llamo a `restrict_access` que activamente patea al usuario, y le informa que no puede acceder alli. Son dos opciones para hacer lo mismo, esta otorga mas información, siendo mas agresiva a la vez.
    Otra opción sería restringiendo las `routes` directamente, pero [aquí](https://anadea.info/blog/rails-authentication-routing-constraints-considered-harmful) se explica muy bien por qué se desaconseja. Es mejor restringir controladores.
  * Luego de tantos errores quise agregar alguna forma de visualizarlos. Para eso hice [esto](https://web-crunch.com/posts/custom-error-page-ruby-on-rails) Aunque luego quite las excepciones, porque rails te continua mandando a una pagina de redirección. quizás hay que probarlo en *production* de verdad.
  * Algo que no se pedía pero quise agregar fue una búsqueda simple. Como los libros se pueden visualizar en una barra lateral, decidí hacer la busqueda por titulo y contenido de la nota, para lo que tuve que [investigar](https://stackoverflow.com/questions/59575397/search-text-in-actiontext-attribute) un poco como acceder al contenido del texto rico.
  * Por último qise implementar la funcionalidad que tenia en la versión anterior que era poder bajar pdfs en archivos separados, pero no fue posible, si de a uno, pero que baje todas las notas del usuario en archivos separados no, ya que solo se puede llamar una vez a `wickedpdf`, por lo que al lo sumo se puede bajar un archivo por vez
  * Por ultimo algo que me quedó pendiente, aunque no era un requerimiento, fue jugar con la paginacion y el ordenamiento de las listas, para loq ue vi que hay una [librería](https://github.com/ddnexus/pagy) pero no la instalé.
  * P.D: Estoy intentando deployar la app en Heroku para poder probarla alli, pero no se si va a poder ser.