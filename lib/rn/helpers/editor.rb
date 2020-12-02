module RN
  class Editor

    def self.edit(filepath)
      prompt = TTY::Prompt.new
      opt = prompt.select("Choose your destiny, i mean, editor:", cycle: true) do |menu|
        menu.default 1

        menu.choice "Choose from your system", 1
        menu.choice "Use my wonderfully programmed editor (will overwrite file if exists)", 2
        menu.choice "PBRUSH.EXE", 3, disabled: "(only win 3.11)"
      end
      if opt == 1
        getEditorFromSystem(filepath)
      elsif opt == 2
        prompt.ok("👍👍 Very Nice 👍👍")
        basicEditor(filepath)
      end
    end

    def self.getEditorFromSystem(filepath)
      editor = TTY::Editor.new(prompt: "Which editor do you fancy?")
      editor.open(filepath)
    end

    def self.basicEditor(filepath)
      prompt = "RN>> "
      eof = "EON"
      eof_feedback = " [End Of Note]\n"
      File.open(filepath, File::RDWR|File::CREAT, 0644) {|f|
        f.flock(File::LOCK_EX)
        f.rewind
        print "\nWrite the contents of the note below.\nYou can write multiple lines.\nEnd the note with '#{eof}' + [Enter].\n\n#{prompt}"
        content = ""
        input_line = STDIN.gets
          while input_line && input_line.chomp != eof
            content << input_line
            print "#{prompt}"
            input_line = STDIN.gets
          end
        print eof_feedback
        f.write content
        f.truncate(f.pos)
      }
    end

    def self.viewer(filepath)
      long = File.foreach(filepath).collect{ |line| line.size }
      title = "Title: #{File.basename(filepath, ".*")}"
      long << title.size
      ancho = long.max + 2
      puts "+#{'-'*ancho}+"
      puts "|#{title.center(ancho)}|"
      puts "+#{'-'*ancho}+"
      File.foreach(filepath) { |line| puts "| #{line.chomp.ljust(ancho-1)}|" }
      puts "+#{'-'*ancho}+"
    end

  end
end