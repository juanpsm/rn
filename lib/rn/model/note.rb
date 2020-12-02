module RN
  class Note
    attr_accessor :path, :title, :bookname

    def initialize(title, bookname=nil)
      @title = title
      book = Book.lookup(bookname)
      if book
        @bookname = book.name
      end
      @path = FileManager.filePath(title, bookname)
    end

    def exists?
      FileManager.fileExists?(self.title, self.bookname)
    end

    def self.create(title, bookname=nil)
      note = self.new(title, bookname)
      if note.exists?
        return false
      end
      FileManager.createFile(note.title, note.bookname)
      Editor.edit(note.path)
      return note
    end

    def self.lookup(title, bookname)
      # p "note in look", 
      note = self.new(title, bookname)
      if note.exists?
        return note
      end
      return nil
    end

    def self.delete(note)
      note = self.lookup(note.title, note.bookname) if note
      if note
        FileManager.deleteFile(note.title, note.bookname)
        return true
      end
      return false
    end

    def self.edit(note)
      if note && self.lookup(note.title, note.bookname)
        Editor.edit(note.path)
        return true
      end
      return false
    end

    def self.show(note)
      if note && self.lookup(note.title, note.bookname)
        Editor.viewer(note.path)
        return true
      end
      return false
    end

    def self.rename(old_title, new_title, bookname)
      old_note = self.new(old_title, bookname)
      new_note = self.new(new_title, bookname)
      if (!old_note.exists? || new_note.exists?)
        warn "Note '#{old_title}' does not exist#{" in book '#{bookname}'" if bookname}." unless old_note.exists?
        warn "Note '#{new_title}' already exists#{" in book '#{bookname}'" if bookname}." if new_note.exists?
        return false
      end
      FileManager.renameFile(old_note.path, new_note.path)
      warn "Renamed note '#{old_title}' to '#{new_title}'"
      return true
    end

    def to_s
      "<Note Title: '#{@title}' Book: '#{@bookname}'>"
    end

    def self.exportNote(note, bookname)
      # hay que arreglar esto de buscar las notas, chamuya un poco cuando no encuentra el libro, sale parche
      if note && self.lookup(note.title, note.bookname) && bookname == note.bookname
        puts "Calling exporter for#{" global" unless note.bookname} note '#{note.title}'#{" from book '#{note.bookname}'" if note.bookname}."
        Exporter.export([note])
        return true
      end
      return false
    end
  end
end