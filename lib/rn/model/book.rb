module RN
  class Book
    attr_accessor :path, :name
    GLOBAL_BOOK = "#{__dir__}/../../../files"

    def self.makePath(name)
      File.absolute_path("#{GLOBAL_BOOK}/#{name}")
    end

    def initialize(name="My Book")
      @name = name
      @path = Book.makePath(name)
    end

    def exists?
      File.directory?(self.path)
    end

    def self.create(name)
      book = self.new(name)
      if book.exists?
        # warn "El cuaderno ya existe"
        return false
      end
      FileUtils.mkdir_p(book.path)
      # warn "Directorio: #{self.path}"
      # warn "Created book: #{self.name}"
      return book
    end

    def self.rootContentPaths
      Dir["#{GLOBAL_BOOK}/*"]
    end

    def self.rootNotesPaths
      self.rootContentPaths.reject{|file| File.directory?(file)}
    end

    def self.deleteRootNotes
      files = self.rootNotesPaths
      files.each do
        |file| 
        unless File.directory?(file) then
          FileUtils.remove(file)
          puts "Removed file #{file}"
        end
      end
      puts "Removed #{files.size} files"
    end

    def self.lookup(name)
      book = self.new(name)
      unless book.exists?
        return nil
      end
      return book
    end

    def self.delete(name)
      book = self.new(name)
      if book.exists?
        FileUtils.rm_rf(book.path)
        warn "Removed Folder '#{book.path}'"
        return true
      end
      return false
    end

    def self.getAllPaths
      self.rootContentPaths.select{|file| File.directory?(file)}
    end

    def self.getAllNames
      self.getAllPaths.each.collect{|route| File.basename(route)}
    end

    def self.rename(old_name, new_name)
      old_book = self.new(old_name)
      new_book = self.new(new_name)
      if (!old_book.exists? || new_book.exists?)
        warn "Book '#{old_name}' does not exist." unless old_book.exists?
        warn "Book '#{new_name}' already exists." if new_book.exists?
        return false
      end
      FileUtils.mv old_book.path, new_book.path
      warn "Renamed book '#{old_name}' to '#{new_name}'"
      return true
    end

    def self.rootNotesPaths
      self.rootContentPaths.reject{|file| File.directory?(file)}
    end

    def self.rootNotes
      self.rootNotesPaths.each.collect{|route| File.basename(route, ".*")}
    end

    def self.getNotes(name)
      Dir["#{self.makePath(name)}/*"].reject{|file| File.directory?(file)}.each.collect{|route| File.basename(route, ".*")}
    end

    def to_s
      "<Book Name: '#{@name}' Path: '#{@path}'>"
    end
  end
end