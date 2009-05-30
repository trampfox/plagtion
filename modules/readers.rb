=begin

  The module Readers contains functions for extracting the text content 
  from different kind of files.
 
  The only externally callable function is Readers::get_text(path)
  that given a file name returns a string with the text content, or 
  the empty string if the the file type is unknown or an error occurs

=end 

require 'rubygems'
require 'hpricot'
require 'htmlentities'
require 'iconv'
require 'kconv'
require 'open-uri'
require 'logger'


# create a log file and store it in a global variable 
$logger = Logger.new('log/logfile.log', 'daily')
$error_logger = Logger.new('log/error.log', 'daily')


module Readers

  class ReaderError < StandardError
  end

  def Readers.get_text(path)
  	if ($platform.include?("linux"))
=begin
	  	if (path =~ /^http:\/\/.*$/) != nil
=end
			# provare a controllare path per html2text
		    begin
		      #ext = File.extname(path).downcase
		      ext = get_ext(path)
		      puts ext
		      case ext
		      when /(html|php|asp)/:
		      	if $html2textFlag == true 
		      		html_reader_system(path)
		      	else
		      		html_reader(path)
		      	end #if
		      when "pdf": pdf_reader(path)
		      when "doc": word_reader(path)
		      when "txt": text_reader(path)
		      #else unknown_type_reader(path)
		      else 
		      	if $html2textFlag == true 
		      		html_reader_system(path)
		      	else
		      		html_reader(path)
		      	end #if
		      end #case
		    rescue Readers::ReaderError => msg
		      # send message to log file
		      $error_logger.error(msg)
		      return ""  
		    end
		   #end # if
		elsif ($platform.include?("mswin"))
			if (path =~ /^http:\/\/.*$/) != nil
	  		html_reader(path)
			else
				begin
		      ext = File.extname(path).downcase
		      case ext
		      when /\.html?$/: html_reader(path)
		      when /\.php?$/: html_reader(path)
		      when /\.asp?$/: html_reader(path)
		      when ".txt": text_reader(path)
		      else unknown_type_reader(path)
		      end #case
		      rescue Readers::ReaderError => msg
		      	# send message to log file
		      	$error_logger.error(msg)
		      	return ""  
		    end #rescue
		   end #if
	  end #if
  end


  # ---------- handling of a file of unknown type 
  def Readers.unknown_type_reader(path)
    # send warning to log file
    $logger.warn("Unknown file type #{path}")
    return ""
  end

  # ---------- pdf conversion 
  def Readers.pdf_reader(path)
  	puts "call pdf reader"																							# DEBUG puts
    options = "-enc Latin1 -nopgbrk"
    filename = "tmp/pdf_temp.pdf"
    open(filename,"w").write(open(path).read)
    pdf_text = %x{pdftotext #{options} #{filename} - 2>/dev/null}
    #pdf_text = system("pdftotext #{options} #{path} - 2>/dev/null")
    # puts $?.exitstatus
    if $?.exitstatus == 127
      raise ReaderError, 'pdftotext(1) missing'
    elsif $?.exitstatus != 0
      raise ReaderError, "Failed converting pdf file: #{path}"
    else
      return pdf_text
    end
  end


  # ----------- word conversion
  def Readers.word_reader(path)
    options = "-m 8859-1"
    word_text = %x{antiword #{options} #{path}  2>/dev/null}
    #word_text = system("antiword #{options} #{path}  2>/dev/null")
    # puts $?.exitstatus
    if $?.exitstatus == 127
      raise ReaderError, 'antiword(1) missing'
    elsif $?.exitstatus != 0
      raise ReaderError, "Failed converting word file: #{path}"
    else
      return word_text
    end
  end


  # ---------- text: only utf8 -> iso-8859-1 conversion
  def Readers.text_reader(path)
    begin
      s = IO.read(path)
      s = Iconv.conv('utf-8','iso-8859-1',s) if s.isutf8
      return s
    rescue StandardError => msg
    	$logger.error("Readers::text_reader") {msg}
      raise ReaderError, "Failed converting text file: #{path}"
    end
  end


  # ---------- html coversion 
  def Readers.html_reader(path)
  	puts "call html"																							# DEBUG puts
    begin
      doc = Hpricot(open(path))
      text = html2text(doc)
      text.gsub!(/\n\s+\n/, "\n\n") # remove groups of empty lines
      return text
    rescue StandardError => msg
    	$logger.error("Readers::html_reader") {msg}
      raise ReaderError, "Failed converting html file: #{path}"
    end
  end

  def Readers.html2text(a)
    if(a.respond_to? :children) && (a.children != nil)
      a.children.map { |x| html2text(x) }.join
    elsif a.text?
      s = a.to_html  # needed to preserve entities
      htmlstring2text(s)
    end
  end

  def Readers.htmlstring2text(s)
    if !s.isutf8   # if this is not utf8 convert it
      # s.gsub!("\222","'")     # (0x92) single quote char cp1250
      # the above gsub was removed since Iconv accepts \222 as an 8859-* char 
      s = Iconv.conv('utf-8','iso-8859-1',s)
    end
    s = HTMLEntities.new.decode(s)  # convert entities to utf-8
    # go back to 8859-1 ignoring charcters without a 8859-1 correspondent
    # this way we get rid of exotic symbols...
    s = Iconv.conv('iso-8859-1//IGNORE','utf-8',s)
    # this last conversion can produce the infamuos \222=0x92 character
    # which is not an iso-8859-* character. Get rid of it! 
    s.gsub!("\222","'")     # single quote cp1250
    return s
  end

	# html to text method that uses html2text external program (only on GNU/Linux machine)	
	def Readers.html_reader_system(path)
		puts "call html system"  																				# DEBUG puts
    text = %x{html2text #{path}}
    #text = system("html2text #{path}")
    # puts $?.exitstatus
    if $?.exitstatus == 127
      raise ReaderError, 'html2text(1) missing'
    elsif $?.exitstatus != 0
      raise ReaderError, "Failed converting html file: #{path}"
    else
      return text
    end
  end
end

# simple method to get the extension of file pointed by passed url
	def get_ext(url)
		if url.include?(".html")
			return "html"
		elsif url.include?(".htm")
			return "html"
		elsif url.include?(".xhtml")
			return "html"
		elsif url.include?(".shtml")
			return "html"
		elsif url.include?("jsp")
			return "html"
		elsif url.include?(".php")
			return "php"
		elsif url.include?(".asp")
			return "asp"
		elsif url.include?(".aspx")
			return "asp"
		elsif url.include?(".pdf")
			return "pdf"
		elsif url.include?(".doc")
			return "doc"
		elsif url.include?(".txt")
			return "txt"
		else
			return "html"
		end #if
	end #get_ext
	
if ARGV[0]
  puts Readers::get_text(ARGV[0])
end

