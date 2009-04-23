#!/usr/bin/env ruby
############################################################################
#    Copyright (C) 2009 by Davide Monfrecola                               #
#    davide.monfrecola@gmail.com                                           #
#                                                                          #
#    This program is free software; you can redistribute it and#or modify  #
#    it under the terms of the GNU General Public License as published by  #
#    the Free Software Foundation; either version 2 of the License, or     #
#    (at your option) any later version.                                   #
#                                                                          #
#    This program is distributed in the hope that it will be useful,       #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#    GNU General Public License for more details.                          #
#                                                                          #
#    You should have received a copy of the GNU General Public License     #
#    along with this program; if not, write to the                         #
#    Free Software Foundation, Inc.,                                       #
#    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
############################################################################

# This class of object contains all the information about a web page
# There's an instance of this class for every web page result
class Document

	# size of word blocks used to build the hash table
	@@bsize = 5
	@@table_size = 209503

	def initialize(url)
		@content = Array.new(0)
    # integers indexes list (M elements). Each index points to the begin of the word block
		@indexTable = Array.new(@@bsize) {Array.new}
		i = 0
    j = @@bsize - 1

		# read the file pointed by url. String -> local file / URI -> web file 
		if (url.kind_of?(String))
			filename = url.split('.')
			# text file
			if (filename.include?("txt"))
				@content = IO.read(url).downcase!.split(/\W+/u)
			# pdf file
			elsif (filename.include?("pdf"))
				#pdftotext problem: it uses UTF-8 encoding
				# special letters (like è,ò,à,ù,ì) will not be represented
				command = "pdftotext "+url
				system(command)
				textfile = url[0..url.length-4]+"txt"
				puts textfile
				@content = IO.read(textfile).downcase!.split(/\W+/u)
			end #if
		elsif (url.kind_of?(URI::HTTP))
			@content = htmlfile2text(url)
			file = File.new("./tmp/#{@@count}-#{@title[0,10]}", "w")
			file.puts textdoc
			file.close
		end #if
		
		
		# convertirlo se necessario
		# parsing
		# mem risultati in variabili di instanza (quelle iniz sopra)
	end #init
	
	def parse(s)
	
	end #parse
	
	def doc_name()
	
	end #doc_name
	
	def to_s()
	
	end #to_s
	
	def num_words()
	
	end #num_words
	
	private
	# read and convert (if it's not a text file) the object linked by url
	def Document.read_text(url)
		
	end #read_text
	
	def Document.hash_array
	
	end #hash_array
	
end # class

class MasterDocument < Document

	def initialize(url)
		super(url)
	end #init
	
	def get_words(url)
	
	end #get_words
	
	def search_overlaps(url)
	
	end #search_overlaps 

end #class


=begin

Metodi da fare:
- Ricerca similarità tra testo in input e obj ResultPage

Domande:
- Ricerca (algo Rabin Karp) : elevazione a potenza per i vari blocchi (come procede)

=end
