module RN
  class Book
    attr_accessor :path, :name

    def initialize(name="My Book")
      @name = name
      @path = FileManager.folderPath(name)
    end

    def exists?
      # File.directory?(self.path)
      FileManager.folderExists?(self.name)
    end
  
    def self.lookup(name)
      book = self.new(name)
      unless book.exists?
        return nil
      end
      return book
    end

    def self.create(name)
      book = self.new(name)
      if book.exists?
        return false
      end
      FileManager.createFolder(book.name)
      return book
    end

    def self.deleteRootNotes
      FileManager.deleteRootNotes
    end

    def self.delete(name)
      book = self.lookup(name)
      if book
        FileManager.deleteFolder(book.name)
        return true
      end
      return false
    end

    def self.getAllNames
      FileManager.getAllFolderNames
    end

    def self.rename(old_name, new_name)
      FileManager.renameFolder(old_name, new_name)
    end

    def self.rootNotesPaths
      FileManager.rootNotesPaths
    end

    def self.rootNotes
      FileManager.rootNotesNames
    end

    def self.getNotes(name)
      FileManager.getNotesFromFolder(name)
    end

    def to_s
      "<Book Name: '#{@name}' Path: '#{@path}'>"
    end
  end
end