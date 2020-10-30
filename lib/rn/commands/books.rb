module RN
  module Commands
    module Books
      GLOBAL_BOOK = "#{__dir__}/../../../files"

      def self.path(name)
        File.absolute_path("#{GLOBAL_BOOK}/#{name}")
      end

      def self.rootContent
        Dir["#{GLOBAL_BOOK}/*"]
      end 

      def self.rootNotesRoutes
        self.rootContent.reject{|file| File.directory?(file)}
      end

      def self.rootNotes
        self.rootNotesRoutes.each.collect{|route| File.basename(route, ".*")}
      end

      def self.getNotes(name)
        Dir["#{self.path(name)}/*"].reject{|file| File.directory?(file)}.each.collect{|route| File.basename(route, ".*")}
      end

      def self.getAllRoutes
        self.rootContent.select{|file| File.directory?(file)}
      end

      def self.getAllNames
        self.getAllRoutes.each.collect{|route| File.basename(route)}
      end

      def self.exists?(name)
        File.directory?(Books.path(name))
      end

      class Create < Dry::CLI::Command
        desc 'Create a book'

        argument :name, required: true, desc: 'Name of the book'

        example [
          '"My book" # Creates a new book named "My book"',
          'Memoires  # Creates a new book named "Memoires"'
        ]

        def call(name:, **)
          # warn "TODO: Implementar creación del cuaderno de notas con nombre '#{name}'.\nPodés comenzar a hacerlo en #{__FILE__}:#{__LINE__}."
          dir = Books.path(name)
          if Books.exists?(name)
            warn "El cuaderno ya existe"
            return false
          end
          FileUtils.mkdir_p(dir)
          warn "Directorio: #{dir}"
          warn "Created book: #{name}"
          return true
        end
      end

      class Delete < Dry::CLI::Command
        desc 'Delete a book'

        argument :name, required: false, desc: 'Name of the book'
        option :global, type: :boolean, default: false, desc: 'Operate on the global book'

        example [
          '--global  # Deletes all notes from the global book',
          '"My book" # Deletes a book named "My book" and all of its notes',
          'Memoires  # Deletes a book named "Memoires" and all of its notes'
        ]

        def call(name: nil, **options)
          global = options[:global]
          # warn "TODO: Implementar borrado del cuaderno de notas con nombre '#{name}' (global=#{global}).\nPodés comenzar a hacerlo en #{__FILE__}:#{__LINE__}."
          files = Book.rootContent
          if global then
            files.each do
              |file| 
              unless File.directory?(file) then
                FileUtils.remove(file)
                puts "Removed #{file}"
              end
            end
            return true
          else
            dir = Books.path(name)
            if Books.exists?(name)
              FileUtils.rm_rf(dir)
              warn "Removed #{dir}"
              return true
            else
              warn "No existe el directorio #{dir}"
              return false
            end
          end
        end
      end

      class List < Dry::CLI::Command
        desc 'List books'

        example [
          '          # Lists every available book'
        ]

        def call(*)
          # warn "TODO: Implementar listado de los cuadernos de notas.\nPodés comenzar a hacerlo en #{__FILE__}:#{__LINE__}."
          books = Books.getAllNames
          # puts "\nBooks: #{books}"
          books.each_slice(5) { |row| puts row.map{|e| "%10s" % e}.join("  ") }
        end
      end

      class Rename < Dry::CLI::Command
        desc 'Rename a book'

        argument :old_name, required: true, desc: 'Current name of the book'
        argument :new_name, required: true, desc: 'New name of the book'

        example [
          '"My book" "Our book"         # Renames the book "My book" to "Our book"',
          'Memoires Memories            # Renames the book "Memoires" to "Memories"',
          '"TODO - Name this book" Wiki # Renames the book "TODO - Name this book" to "Wiki"'
        ]

        def call(old_name:, new_name:, **)
          # warn "TODO: Implementar renombrado del cuaderno de notas con nombre '#{old_name}' para que pase a llamarse '#{new_name}'.\nPodés comenzar a hacerlo en #{__FILE__}:#{__LINE__}."
          old_dir = Books.path(old_name)
          new_dir = Books.path(new_name)
          if (!Books.exists?(old_name) || Books.exists?(new_name))
            warn "Book '#{old_name}' does not exist." unless Books.exists?(old_name)
            warn "Book '#{new_name}' already exists." if Books.exists?(new_name)
            return false
          end
          FileUtils.mv old_dir, new_dir
          warn "Renamed book '#{old_name}' to '#{new_name}'"
          return true
        end
      end
    end
  end
end
