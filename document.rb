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
	@@expTable = []
	@last_hashvalue = 0
	@last_fbvalue = 0
	@doc_name = ""
	@text = ""

	def initialize(url)
		i = 0
    j = @@bsize - 1
		@doc_name = url
		@content = Array.new(0) # Array of elements [w, pos]
    # integers indexes list (M elements). Each index points to the begin of the word block
		@indexTable = Array.new(@@table_size) {Array.new(0)}
		if @@expTable == []
			init_expTable
			$logger.info("Document") {"@@expTable initialized"}
		end #if
		if (url.kind_of?(URI::HTTP))
			@content = parse(htmlfile2text(url))
			file = File.new("./tmp/#{@@count}-#{@title[0,10]}", "w")
			file.puts @content
			file.close
			@@count += 1
		else # local files
			if ((@text = Readers::get_text(url)) == "")
				puts "Error while reading file. See the logfile for more information"
				exit()
			else
				@content = parse(@text)
				$logger.info("Document") {"#{url} read (local file)"}
			end #if
		end #if
=begin
			# calculate the hash of the input text block
			
=end
	end #init
	
	def blockhash(a)
		hasharray = Array.new(0)
		sum = 0
		i = @@bsize-1
		for x in a
			hasharray << (x.hash * @@expTable[i]) % @@table_size
			i = i-1
		end
		hasharray.each {|elem| sum = sum + elem}
		@last_hashvalue = sum % @@table_size
		@last_fbvalue = hasharray[0] # farlo solo se non master document
		#puts "last_fbvalue-> #{@last_fbvalue} last_hash-> #{@last_hashvalue}" 
		return (sum % @@table_size) # return hash of block
	end #blockhash
	
	# blockhash using the Bentley Ilroy algorithm
	# a: word list
	def blockhash_Bentley(a)
		hasharray = Array.new(0)
		temp = 0
		temp = ((@last_hashvalue - @last_fbvalue) * P)+(a[@@bsize-1].hash)
		@last_hashvalue = temp % @@table_size
		@last_fbvalue = (((a[0].hash) * @@expTable[@@bsize-1])) % @@table_size
		return (temp % @@table_size) # return hash of block
	end # blockhash_Bentley
	
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
	
	private
	
	# convert accented vowels in place
	def remove_accent!(s)
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
	def parse(s,wlimit=3)
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
	
	# initialize the expTable
	def init_expTable
		for i in 0...@@bsize
			@@expTable << P**i
		end
	end #expTable
end # class

class MasterDocument < Document
	
	def initialize(url)
		super(url)
		i = 0
		# calculate the block hash and populate the indexTable
		puts "=== blockHash (Document)==="
			while i < @content.length-1 
				wlist = get_words(i, @@bsize)
				hashValue = blockhash(wlist)  # i is the index of the first word in @content
				@indexTable[hashValue] << i 
				$logger.debug("MasterDocument") {"#{wlist} ---> index #{@content[i][1]} hashValue -> #{hashValue}"}
				i = i+@@bsize
			end # while
		puts "=== end blockHash ==="
=begin
			puts "=== searching on #{NUM_OF_SEARCHS} random block ==="
			google = GoogleCachedSearchEngine.new(self, @content, @@bsize)
			resultUrl = google.search(NUM_OF_PAGES) # return an UrlManager obj 		
=end
	end #init
	
	def search_overlaps(doc)
		flag = 0 # if zero call blockhash else call Bentley McIlroy algorithm
		i = 0
		overlap = Overlap.new(self, doc)
		
		while i < (doc.content).length
			wlist = doc.get_words(i, @@bsize) # wlist contains the block
			return overlap if (wlist.size < 5)
			if (i == 0) || (flag == 0)
				index = blockhash(wlist)
			else
				index = blockhash_Bentley(wlist)
			end #if
			if (search_hashValue(index) == true)
				for y in 0...@indexTable[index].size
					if (block_control(doc, wlist, @indexTable[index][y], i))
						size = @extended_index["end_copy"] - @extended_index["start_copy"]
						puts "!!== block of #{size} words found ==!!" 
						#puts ext_list = doc.get_words(@extended_index["start_copy"], size)
						overlap.add(size, @extended_index) # add the overlap region that has just founded
						i += size
						flag = 0
					else
						#puts "== block not found =="
						#puts wlist
						i = i+1
						flag = 1
					end #if
					
				end #for
			else
				#puts "== block not found =="
				#puts wlist
				i += 1
				flag = 1
			end #if
			
		end #while
		return overlap
	end #search_overlaps 

	# control if the founded block hash is the same block 
	# return the size of the founded string
	# index_first: index of the first word block in @content
	# index_second: index of the first word block in doc.content
	def block_control(doc, wlist, index_first, index_second)
			wlist_master = get_words(index_first, @@bsize) # wlist contains the block
			if (wlist_master == wlist)
				extend_block(doc, wlist_master,index_first, index_second)
				return true
			end #if
			return false # if the founded block it's not the same return false (collision)
	end
	
	# i: index in @content
	# j: index in @content_2ndfile
	# usare slo gli indici
	def extend_block(doc, wlist_master, i, j)
		@extended_index = {} # hash with key "start_master", "start_copy", "end_master" and "end_copy"
		extension_i = i-1
		extension_j = j-1
		# left extension
		while (@content[extension_i][0] == doc.content[extension_j][0])
			extension_i -= 1
			extension_j -= 1
			break if (extension_i < 0) || (extension_j < 0)
		end  #while
		@extended_index["start_master"] = extension_i+1
		@extended_index["start_copy"] = extension_j+1
		# right extension
		extension_i = i+@@bsize
		extension_j = j+@@bsize
		while (@content[extension_i][0] == doc.content[extension_j][0])
			extension_i += 1
			extension_j += 1
			break if (extension_i > @content.size-1) || (extension_j > doc.content.size-1)
		end #while
		@extended_index["end_master"] = extension_i
		@extended_index["end_copy"] = extension_j
		if extension_i > i+@@bsize || @extended_index["start_master"] < i
			puts "< extension done >"
		end
	end # extend_block
	
	def search_hashValue(value)
		return @indexTable[value][0] != nil
	end #search hash value
end #class


=begin

Metodi da fare:
- Ricerca similarità tra testo in input e obj ResultPage

=end
