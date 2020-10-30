prompt = "RN>> "
eof = "EON"
File.open("asd.txt", File::RDWR|File::CREAT, 0644) {|f|
  f.flock(File::LOCK_EX)
  f.rewind
  print "\nWrite the contents of the note below.\nYou can write multiple lines.\nEnd the note with '#{eof}' + [Enter].\n\n#{prompt}"
  content = ""
  input_line = gets
    while input_line.chomp != eof
      print "#{prompt}"
      input_line = gets
      content << input_line unless input_line.chomp == eof
    end
  f.write content
  f.truncate(f.pos)
}