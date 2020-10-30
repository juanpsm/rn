file = 'test.rn'
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