module RN
  class Note
    attr_accessor :path, :title, :book

    def self.makePath(title, book=nil)
      File.join("#{Book.makePath(book)}", "#{title}.rn")
    end

    def initialize(title, book=nil)
      @title = title
      if book
        @book = Book.lookup(book).name
      end
      @path = Note.makePath(title, book)
    end

    def self.create(title, book=nil)
      note = self.new(title, book)
      if note.exists?
        warn "The file '#{title}' already exists#{" in folder '#{book}'" if book}."
        return false
      end
      File.new(note.path, "w+")
      warn "Created file '#{title}'#{" in folder '#{book}'" if book}."
      puts "Path: #{note.path}"
      self.editor(note)
      return note
    end

    def self.lookup(title, book)
      note = self.new(title, book)
      if note.exists?
        return note
      end
      return nil
    end

    def self.delete(note)
      note = self.lookup(note.title, note.book) if note
      if note
        File.delete(note.path)
        warn "Removed file '#{note.path}'"
        return true
      end
      return false
    end

    def self.edit(note)
      if note && self.lookup(note.title, note.book)
        self.editor(note)
        return true
      end
      return false
    end

    def self.show(note)
      if note && self.lookup(note.title, note.book)
        self.viewer(note)
        return true
      end
      return false
    end

    def self.rename(old_title, new_title, book)
      old_note = self.new(old_title, book)
      new_note = self.new(new_title, book)
      if (!old_note.exists? || new_note.exists?)
        warn "Note '#{old_title}' does not exist#{" in book '#{book}'" if book}." unless old_note.exists?
        warn "Note '#{new_title}' already exists#{" in book '#{book}'" if book}." if new_note.exists?
        return false
      end
      FileUtils.mv old_note.path, new_note.path
      warn "Renamed note '#{old_title}' to '#{new_title}"
      return true
    end

    def to_s
      "<Note Title: '#{@title}' Book: '#{@book}'>"
    end

    def exists?
      File.file?(Note.makePath(self.title, self.book))
    end

    def self.editor(note)
      editor = TTY::Editor.new(prompt: "Which editor do you fancy?")
      editor.open(note.path)
    end

    def self.basicEditor(note)
      file = note.path
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

    def self.viewer(note)
      file = note.path
      long = File.foreach(file).collect{ |line| line.size }
      title = "Title: #{File.basename(file, ".*")}"
      long << title.size
      ancho = long.max + 2
      puts "+#{'-'*ancho}+"
      puts "|#{title.center(ancho)}|"
      puts "+#{'-'*ancho}+"
      File.foreach(file) { |line| puts "| #{line.chomp.ljust(ancho-1)}|" }
      puts "+#{'-'*ancho}+"
    end
  end
end