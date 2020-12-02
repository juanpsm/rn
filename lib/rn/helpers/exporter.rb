begin
  require 'github/markup'
  require 'date'
rescue LoadError
  # Rely on extensions instead.
end

module RN
  class Exporter

    def self.export(notes)
      prompt = TTY::Prompt.new
      opt = prompt.select("Choose your DESTINY, i mean, format:", cycle: true) do |menu|
        menu.default 1

        menu.choice "HTML", 1
        menu.choice "PDF", 2, disabled: "(not yet)"
        menu.choice "LaTeX", 3, disabled: "(in some distant future)"
        menu.choice "Cancel", :cancel
      end
      if opt == 1
        export_to_format(notes, "html")
      elsif opt == 2
        export_to_format(notes, "pdf")
      elsif opt == :cancel
        return false
      end
    end

    def self.export_to_format(notes, format)
      prompt = TTY::Prompt.new
      opt = 2
      if notes.size > 1
        opt = prompt.select("How many files do you fancy me to output?", cycle: true) do |menu|
          menu.default 1

          menu.choice "Put all together", 1
          menu.choice "One per file", 2
          menu.choice "Cancel", :cancel
        end
      end
      filetime = Time.now.strftime("%d-%m-%Y-%H-%M-%S")
      savefolder = "#{FileManager.exportFolder()}/RNExported_#{filetime}"
      if opt == 1
        savefile = "#{savefolder}.#{format.downcase}"
        savefile = prompt.ask("Output File?", default: savefile)
        marked_string = ''
        notes.each do
          |note|
          marked_string << add_meta(note)
        end
        FileManager.createHTML(savefile, marked_string)
        FileManager.deleteTmp()

      elsif opt == 2
        prompt.ok("Exporting #{notes.size} files...")
        savefolder = prompt.ask("Output Folder?", default: "#{FileManager.exportFolder()}/")
        notes.each do
          |note|
          p savefile = File.join("#{savefolder}", "#{note.title}.#{format.downcase}")
          marked_string = add_meta(note)
          FileManager.createHTML(savefile, marked_string)
        end
        FileManager.deleteTmp()
      elsif opt == :cancel
        return false
      end
    end

    def self.add_meta(note)
      meta_string = ''
      meta_string << "<small><em>title</em>: <strong>#{note.title}</strong></small>&nbsp;|&nbsp;"
      meta_string << "<small><em>book</em>: #{note.bookname ? "<strong>#{note.bookname}</strong>" : "<em>global</em>"} </small><br>"
      meta_string << markup_file(note.path)
      meta_string << "<hr>"
      meta_string
    end

    def self.processor
      md_options = {
        tables: true,
        fenced_code_blocks: true,
        autolink: true,
        strikethrough: true,
        hard_wrap: true,
        prettify: true,
        space_after_headers: true
      }
      Redcarpet::Markdown.new(Redcarpet::Render::HTML, md_options)
    end

    def self.markup_file(filepath)
        # puts "Marking up #{filepath}"
        # temp = FileManager.createTmp(filepath)
        # return GitHub::Markup.render(filepath, File.read(temp))
        return processor().render(File.read(filepath))
        #return RN::RougeeHelper.rouge_markdown(File.read(filepath))
    end

    private_class_method :export_to_format
  end
end
