#!/usr/bin/env ruby
 
require 'rubygems'
require 'hpricot'
require 'htmlentities'
require 'iconv'
require 'kconv'
require 'open-uri'

@only_text = "&gl=it&strip=1"

def htmlfile2text(fname)
   doc = Hpricot(open(fname))
	 # --- save the html of the current page
	 f = File.new("last.html","w")
	 f.puts doc.to_html
	 f.close
	 text = html2text(doc)
	 text.strip.gsub(/\n{2,}/, "\n\n")
end

def html2text(a)
  if((a.respond_to? :children) && (a.children != nil))
    a.children.map { |x| html2text(x) }.join
  elsif a.text?
    s = a.to_html  # needed to preserve entities
    htmlstring2text(s)
  end
end

def htmlstring2text(s)
  if !s.isutf8   # if this is not utf8 convert it
    # s.gsub!("\222","'")     # (0x92) single quote char cp1250
    # the above gsub was removed since Iconv accepts \222 as an 8859-* char 
    s = Iconv.conv('utf-8','iso-8859-15',s)
  end
  s = HTMLEntities.new.decode(s)  # convert entities to utf-8
  # go back to 8859-1 ignoring charcters without a 8859-1 correspondent
  # this way we get rid of exotic symbols...
  s = Iconv.conv('iso-8859-15//IGNORE','utf-8',s)
  # this last conversion can produce the infamuos \222=0x92 character
  # which is not an iso-8859-* character. Get rid of it! 
  s.gsub!("\222","'")     # single quote cp1250
	#puts "=== Page === #{s}"
  return s
end


if ARGV[0]
  puts htmlfile2text(ARGV[0])
end

=begin
Problema: eliminare spazi bianchi
		* strip non va bene perchè toglie alcuni spazi tra le parole
=end
