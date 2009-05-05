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
	@@count = 0
	@doc_name = ""
	@text = ""

	def initialize(url)
		@doc_name = url
		@content = Array.new(0) # Array of elements [w, pos]
    # integers indexes list (M elements). Each index points to the begin of the word block
		@indexTable = Array.new(@@table_size) {Array.new(0)}
		i = 0
    j = @@bsize - 1
		if (url.kind_of?(URI::HTTP))
			@content = Document.mysplit(htmlfile2text(url))
			file = File.new("./tmp/#{@@count}-#{@title[0,10]}", "w")
			file.puts @content
			file.close
			@@count += 1
		else # local files
			if ((@text = Readers::get_text(url)) == "")
				puts "Error while reading file. See the logfile for more information"
				exit()
			else
				@content = Document.mysplit(@text) 
			end #if
			# calculate the hash of the input text block
			puts "=== blockHash ==="
			while i < @content.length-1
				blockhash(@content[i..j], i, 0)  # i is the index of the first word 
				i = j+1
				j = j+@@bsize
			end # while
			
			puts "=== end blockHash ==="
			puts "=== searching on #{NUM_OF_SEARCHS} random block ==="
			google = GoogleCachedSearchEngine.new(self, @content, @@bsize)
			resultUrl = google.search(NUM_OF_PAGES) # return an UrlManager obj 		
		end #if
	end #init
	
	def blockhash(a, pos, type)
		hasharray = Array.new(0)
		sum = 0
		i = @@bsize-1
		for x in a
			hasharray << x.hash.abs * $expTable[i]
			i = i-1
		end
		hasharray.each {|elem| sum = sum + elem}
		@last_hashvalue = sum
		@last_fbvalue = hasharray[0]
		#puts "last_hasvalue -> #{@last_hashvalue}  last_fbvalue -> #{@last_fbvalue}"
		if (type == 0) # master document
			@indexTable[sum % @@table_size] << pos # posizione della prima parola con un dato hash
		return (sum % @@table_size)
		else # other document
			return (sum % @@table_size) # return hash of block
		end #if
	end #blockhash
	
	# return url used to create self 
	def doc_name()
		return @doc_name
	end #doc_name
	
	def to_s()
		return @text
	end #to_s
	
	# return the words number in the self parsing
	def num_words()
		return @content.size
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
				# at page 319 of programming ruby 
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
			begin
				wordlist << @content[i][0]+" "
			rescue NoMethodError # if the last block is small then 5 words 
				return wordlist
			end #rescue
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
