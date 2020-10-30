module RN
  module Commands
    module Notes

      def self.path(name, book=nil)
        Books.path(book)
        File.join("#{Books.path(book)}", "#{name}.txt")
      end

      def self.exists?(name, book=nil)
        File.file?(self.path(name, book))
      end

      def self.editor(file)
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
      end

      def self.viewer(file)
        long = File.foreach(file).collect{ |line| line.size }
        title = "Title: #{File.basename(file, ".*")}"
        long << title.size
        ancho = long.max + 2
        puts "+#{'-'*ancho}+"
        puts "|#{title.center(ancho)}|"
        puts "+#{'-'*ancho}+"
        File.foreach(file) { |line| puts "|#{line.chomp.center(ancho)}|" }
        puts "+#{'-'*ancho}+"
      end

      class Create < Dry::CLI::Command
        desc 'Create a note'

        argument :title, required: true, desc: 'Title of the note'
        option :book, type: :string, desc: 'Book'

        example [
          'todo                        # Creates a note titled "todo" in the global book',
          '"New note" --book "My book" # Creates a note titled "New note" in the book "My book"',
          'thoughts --book Memoires    # Creates a note titled "thoughts" in the book "Memoires"'
        ]

        def call(title:, **options)
          book = options[:book]
          # warn "TODO: Implementar creación de la nota con título '#{title}' (en el libro '#{book}').\nPodés comenzar a hacerlo en #{__FILE__}:#{__LINE__}."
          if book
            Books::Create.new.call(name:book) unless Books.exists?(book)
          end
          file = Notes.path(title, book)
          if Notes.exists?(title, book)
            warn "A note titled '#{title}' already exists#{" in book '#{book}'" if book}."
            return false
          end
          File.new(file, "w+")
          warn "Created note '#{title}'#{" in book '#{book}'" if book}."
          puts "file: #{file}"
          Notes.editor(file)
          return true
        end
      end

      class Delete < Dry::CLI::Command
        desc 'Delete a note'

        argument :title, required: true, desc: 'Title of the note'
        option :book, type: :string, desc: 'Book'

        example [
          'todo                        # Deletes a note titled "todo" from the global book',
          '"New note" --book "My book" # Deletes a note titled "New note" from the book "My book"',
          'thoughts --book Memoires    # Deletes a note titled "thoughts" from the book "Memoires"'
        ]

        def call(title:, **options)
          book = options[:book]
          # warn "TODO: Implementar borrado de la nota con título '#{title}' (del libro '#{book}').\nPodés comenzar a hacerlo en #{__FILE__}:#{__LINE__}."
          file = Notes.path(title, book)
          unless Notes.exists?(title, book)
            warn "There is not any note titled '#{title}'#{" in book '#{book}'" if book}."
            return false
          end
          File.delete(file)
          warn "Deleted note '#{title}'#{" from book '#{book}'" if book}."
          puts "file: #{file}"
          return true
        end
      end

      class Edit < Dry::CLI::Command
        desc 'Edit the content of a note'

        argument :title, required: true, desc: 'Title of the note'
        option :book, type: :string, desc: 'Book'

        example [
          'todo                        # Edits a note titled "todo" from the global book',
          '"New note" --book "My book" # Edits a note titled "New note" from the book "My book"',
          'thoughts --book Memoires    # Edits a note titled "thoughts" from the book "Memoires"'
        ]

        def call(title:, **options)
          book = options[:book]
          # warn "TODO: Implementar modificación de la nota con título '#{title}' (del libro '#{book}').\nPodés comenzar a hacerlo en #{__FILE__}:#{__LINE__}."
          file = Notes.path(title, book)
          unless Notes.exists?(title, book)
            warn "There is not any note titled '#{title}'#{" in book '#{book}'" if book}."
            return false
          end
          warn "Opened note '#{title}'#{" in book '#{book}'" if book}."
          puts "file: #{file}"
          Notes.editor(file)
          return true
        end
      end

      class Retitle < Dry::CLI::Command
        desc 'Retitle a note'

        argument :old_title, required: true, desc: 'Current title of the note'
        argument :new_title, required: true, desc: 'New title for the note'
        option :book, type: :string, desc: 'Book'

        example [
          'todo TODO                                 # Changes the title of the note titled "todo" from the global book to "TODO"',
          '"New note" "Just a note" --book "My book" # Changes the title of the note titled "New note" from the book "My book" to "Just a note"',
          'thoughts thinking --book Memoires         # Changes the title of the note titled "thoughts" from the book "Memoires" to "thinking"'
        ]

        def call(old_title:, new_title:, **options)
          book = options[:book]
          # warn "TODO: Implementar cambio del título de la nota con título '#{old_title}' hacia '#{new_title}' (del libro '#{book}').\nPodés comenzar a hacerlo en #{__FILE__}:#{__LINE__}."
          old_file = Notes.path(old_title, book)
          new_file = Notes.path(new_title, book)
          if (!Notes.exists?(old_title, book) || Notes.exists?(new_title, book))
            warn "Note '#{old_title}' does not exist#{" in book '#{book}'" if book}." unless Notes.exists?(old_title, book)
            warn "Note '#{new_title}' already exists#{" in book '#{book}'" if book}." if Notes.exists?(new_title, book)
            return false
          end
          FileUtils.mv old_file, new_file
          warn "Renamed note '#{old_title}' to '#{new_title}"
          return true
        end
      end

      class List < Dry::CLI::Command
        desc 'List notes'

        option :book, type: :string, desc: 'Book'
        option :global, type: :boolean, default: false, desc: 'List only notes from the global book'

        example [
          '                 # Lists notes from all books (including the global book)',
          '--global         # Lists notes from the global book',
          '--book "My book" # Lists notes from the book named "My book"',
          '--book Memoires  # Lists notes from the book named "Memoires"'
        ]

        def call(**options)
          book = options[:book]
          global = options[:global]
          # warn "TODO: Implementar listado de las notas del libro '#{book}' (global=#{global}).\nPodés comenzar a hacerlo en #{__FILE__}:#{__LINE__}."
          notes = []
          notes << Books.rootNotes unless book
          if !book && !global
            Books.getAllNames.each do
              |each|
              Books.getNotes(each)
              notes << Books.getNotes(each)
            end
          elsif book
            Books.getNotes(book)
            notes = Books.getNotes(book)
          end
          puts "#{"\nTodas las " unless global || book}Notas#{" del cuaderno '#{book}'" if book}:\n"
          notes.flatten!
          notes.each_slice(5) { |row| puts row.map{|e| "%10s" % e}.join("  ") }
        end
      end

      class Show < Dry::CLI::Command
        desc 'Show a note'

        argument :title, required: true, desc: 'Title of the note'
        option :book, type: :string, desc: 'Book'

        example [
          'todo                        # Shows a note titled "todo" from the global book',
          '"New note" --book "My book" # Shows a note titled "New note" from the book "My book"',
          'thoughts --book Memoires    # Shows a note titled "thoughts" from the book "Memoires"'
        ]

        def call(title:, **options)
          book = options[:book]
          # warn "TODO: Implementar vista de la nota con título '#{title}' (del libro '#{book}').\nPodés comenzar a hacerlo en #{__FILE__}:#{__LINE__}."
          file = Notes.path(title, book)
          p  RN::Note.new(title, book)
          unless Notes.exists?(title, book)
            warn "There is not any note titled '#{title}'#{" in book '#{book}'" if book}."
            return false
          end
          warn "Opened note '#{title}'#{" from book '#{book}'" if book}."
          puts "file: #{file}"
          Notes.viewer(file)
          return true
        end
      end
    end
  end
end
