module RN
  class FileManager
    ROOT_FOLDER_NAME = ".my_rns"

    def self.homeFolder
      Dir.home
    end

    def self.rootFolderPath
      File.absolute_path("#{homeFolder()}/#{ROOT_FOLDER_NAME}")
    end

    def self.rootFolder?
      File.directory?(rootFolderPath())
    end

    def self.createRootFolder
        FileUtils.mkdir_p(rootFolderPath()) unless rootFolder?()
    end

    def self.folderPath(name)
      File.absolute_path("#{rootFolderPath()}/#{name}")
    end

    def self.createFolder(name)
      FileUtils.mkdir_p(folderPath(name))
    end

    def self.folderExists?(name)
      File.directory?(folderPath(name))
    end

    def self.rootContentPaths
      Dir["#{rootFolderPath()}/*"]
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

    def self.deleteFolder(name)
      FileUtils.rm_rf(folderPath(name))
      warn "Removed folder '#{name}'"
    end

    def self.getAllFolderPaths
      self.rootContentPaths.select{|file| File.directory?(file)}
    end

    def self.getAllFolderNames
      self.getAllFolderPaths.each.collect{|route| File.basename(route)}
    end

    def self.renameFolder(old_name, new_name)
      old_folder = folderPath(old_name)
      new_folder = folderPath(new_name)
      if (! folderExists?(old_name) || folderExists?(new_name))
        warn "Folder '#{old_name}' does not exist." unless folderExists?(old_name)
        warn "Folder '#{new_name}' already exists." if folderExists?(new_name)
        return false
      end
      FileUtils.mv old_folder, new_folder
      warn "Renamed folder '#{old_name}' to '#{new_name}'"
      return true
    end

    def self.rootNotesPaths
      self.rootContentPaths.reject{|file| File.directory?(file)}
    end

    def self.rootNotesNames
      self.rootNotesPaths.each.collect{|route| File.basename(route, ".*")}
    end

    def self.getNotesFromFolder(name)
      Dir["#{self.folderPath(name)}/*"].reject{|file| File.directory?(file)}.each.collect{|route| File.basename(route, ".*")}
    end

    def self.filePath(name, foldername=nil)
      File.join("#{folderPath(foldername)}", "#{name}.rn")
    end

    def self.fileExists?(name, foldername)
      File.file?(filePath(name, foldername))
    end

    def self.createFile(name, foldername)
      File.new(filePath(name, foldername), "w+")
    end

    def self.deleteFile(name, foldername)
      File.delete(filePath(name, foldername))
      warn "Removed file '#{filePath(name, foldername)}'"
    end

    def self.renameFile(old_filepath, new_filepath)
      FileUtils.mv old_filepath, new_filepath
      warn "Renamed file '#{old_filepath}' to '#{new_filepath}'"
    end


  end
end
