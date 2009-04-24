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
	attr_reader :content
	
	# size of word blocks used to build the hash table
	@@bsize = 5
	@@table_size = 209503

	def initialize(url)
		@content = Array.new(0) # Array of elements [w, pos]
    # integers indexes list (M elements). Each index points to the begin of the word block
		@indexTable = Array.new(@@table_size) {Array.new(0)}
		i = 0
    j = @@bsize - 1

		# read the file pointed by url. String -> local file / URI -> web file 
		if (url.kind_of?(String))
			filename = url.split('.')
			if (filename.include?("txt"))  # text file
				@content = Document.mysplit(IO.read(url))
			elsif (filename.include?("pdf"))  # pdf file
				# pdftotext problem: it uses UTF-8 encoding
				# special letters (like è,ò,à,ù,ì) will not be represented
				command = "pdftotext "+url
				system(command)
				textfile = url[0..url.length-4]+"txt"
				puts textfile
				@content = Document.mysplit(IO.read(textfile)) 
				#puts @content.inspect 
			end #if
			
			# calculate the hash of the input text block
			puts "=== blockHash ==="
			while i < @content.length-1
				blockhash(@content[i..j], i)  # i is the index of the first word 
				i = j+1
				j = j+@@bsize
			end # while
			
			puts "=== end blockHash ==="
			puts @indexTable.size
			puts "=== searching on 5 random block ==="
			google = GoogleCachedSearchEngine.new(self, @content, @@bsize)
			google.search(NUM_OF_PAGES)
			
		elsif (url.kind_of?(URI::HTTP))
			@content = Document.mysplit(htmlfile2text(url))
			file = File.new("./tmp/#{@@count}-#{@title[0,10]}", "w")
			file.puts @content
			file.close		
		end #if
	end #init
	
	def blockhash(a, pos)
		hasharray = Array.new(0)
		sum = 0
		i = @@bsize-1
		for x in a
			hasharray << x.hash * P**i
			i = i-1
		end
		hasharray.each {|elem| sum = sum + elem}
		@indexTable[sum % @@table_size] << pos # posizione della prima parola con un dato hash
	end #blockhash
	
	def doc_name()
	
	end #doc_name
	
	def to_s()
	
	end #to_s
	
	def num_words()
	
	end #num_words
	
	private
	
	# convert accented vowels in place
	def Document.remove_accent!(s)
		s.gsub!(/[àéèìòù]/) do |c|
			case c
				when  /à/: "a"
				when  /ì/: "i"
				when  /ò/: "o"
				when  /ù/: "u"
				else       "e"
			end
		end
		return s
	end

	# parse s into a sequence of words returning the list of words 
	# together with their starting position in the input
	def Document.mysplit(s,wlimit=3)
		wlist = []
		word_def = /[[:alpha:]|àèéìòù]+/ # regex
		s.scan(word_def) do |w| 
			if w.size >= wlimit
				wpos = $`.size          # starting position in s of w
				remove_accent!(w)       # convert accented chars in place
				w.downcase!             # convert case
				wlist << [w, wpos]      # save in list
			end
		end
		wlist
	end
end # class

class MasterDocument < Document

	def initialize(url)
		super(url)
		
	end #init
	
	def get_words(n, k)
		wordlist = []
		for i in n...n+k
			wordlist << @content[i][0]+" "
		end
		return wordlist
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
