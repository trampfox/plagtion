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
class WebDocument
	attr_reader :content
	
	
	@@bsize = 5 															# size of word blocks used to build the hash table
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
		@mutex = Mutex.new
		#@filename = filename
		@content = Array.new(0)	
		@mutex.lock
			@@count += 1								 # Array of elements [w, pos]
		@mutex.unlock
    # integers indexes list (M elements)
    # Each index points to the begin of the word block
		@indexTable = Array.new(@@table_size) {Array.new(0)}
		if @@expTable == []
			init_expTable
			$logger.info("Document") {"@@expTable initialized"}
		end #if
		$logger.info("Document") {"reading #{url}"}
		if ((@text = Readers::get_text(url)) == "")
			puts "Empty file #{url}"
		end #if
		@content = parse(@text)
		$logger.info("Document") {"#{url} read | @content.size:#{@content.size}"}
	end #init
	
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
	
	# return list of k words.
	# n: position of the first word
	# k: number of words
	def get_words(n, k)
		wordlist = []
		for i in n...n+k
			begin
				wordlist << @content[i][0]+" "
			rescue NoMethodError								 # if the last block is small then 5 words 
				return wordlist
			end #rescue
		end
		return wordlist
	end #get_words
	
	private # private method
	
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
		@last_fbvalue = hasharray[0] 						# farlo solo se non master document
		#puts "last_fbvalue-> #{@last_fbvalue} last_hash-> #{@last_hashvalue}" 
		return (sum % @@table_size) 						# return hash of block
	end #blockhash
	
	# blockhash using the Bentley Ilroy algorithm
	# a: word list
	def blockhash_Bentley(a)
		hasharray = Array.new(0)
		temp = 0
		temp = ((@last_hashvalue - @last_fbvalue) * P)+(a[@@bsize-1].hash)
		@last_hashvalue = temp % @@table_size
		@last_fbvalue = (((a[0].hash) * @@expTable[@@bsize-1])) % @@table_size
		return (temp % @@table_size) 						# return hash of block
	end # blockhash_Bentley
	
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
				wpos = $`.size          			# starting position in s of w
				remove_accent!(w)      				# convert accented chars in place
				w.downcase!             			# convert case
				wlist << [w, wpos]      			# save in list
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

end # class WebDocument

class MasterDocument < WebDocument
	
	def initialize(url)
		super(url)
		@resultList = [] # -> for test only. contains Document object
		i = 0
		puts "=== blockHash (Document)===" 				# calculate the block hash and populate the indexTable
			while i < @content.length-1 
				wlist = get_words(i, @@bsize)
				hashValue = blockhash(wlist)  				# i is the index of the first word in @content
				@indexTable[hashValue] << i 
				#$logger.debug("MasterDocument") {"#{wlist} ---> index #{@content[i][1]} hashValue -> #{hashValue}"}
				i = i+@@bsize
			end # while
		# search with Google search engine on a cached page database
=begin
		puts "=== searching on #{NUM_OF_SEARCHS} random block (Google cached)==="
		google = GoogleCachedSearchEngine.new(self, @content, @@bsize)
		# search with Google search engine
		puts "=== searching on #{NUM_OF_SEARCHS} random block (Google cached)==="
		google = GoogleSearchEngine.new(self, @content, @@bsize)
		resultUrl = google.search(NUM_OF_PAGES) 	# return an UrlManager obj 
=end
		puts "=== searching on #{NUM_OF_SEARCHS} random block (Yahoo)==="
		yahoo = YahooSearchEngine.new(self, @content, @@bsize)
		resultUrl = yahoo.search(NUM_OF_PAGES)
		$logger.debug("MasterDocument") {"#{resultUrl}"}
		fetch_url(self, resultUrl, yahoo)
	end #init
	
	# search if there are a common region between self and doc (Document object)
	# to find common region it uses the Bentley McIlroy's algorithm
	# If one is found method "block_control" is called
	# doc: MasterDocument object
	# return an Overlap object
	def search_overlaps(doc)
		flag = 0																 # if zero call blockhash, else call Bentley McIlroy algorithm
		i = 0
		# create new Overlap object that contains the information
		# on the common region found in the copy document
		overlap = Overlap.new(self, doc) 
		
		while i < (doc.content).length
			wlist = doc.get_words(i, @@bsize)			# get a words block from MasterDocument and put it in wlist
			
			if (wlist.size < 5)										# last block may be smaller then 5 words
				if (overlap.num_overlaps > 0)
					return overlap
				else
					return nil
				end #if
			end #if
			
			if (i == 0) || (flag == 0)
				index = blockhash(wlist) 
			else
				index = blockhash_Bentley(wlist) 		# This method use Bentley McIlroy algorithm
			end #if
			if (search_hashValue(index) == true)
				# search for possible hash collision (using block_control) 
				for y in 0...@indexTable[index].size 
					if (block_control(doc, wlist, @indexTable[index][y], i)) 								# true if find a copied block 
						size = @extended_index["end_copy"] - @extended_index["start_copy"]		# size of common block found
						puts "!!== block of #{size} words found ==!!" 
						overlap.add(size, @extended_index) 																		# add the overlap region that has just found
						i += size
						flag = 0
					else
						# continue the search  
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
		if (overlap.num_overlaps > 0)
			return overlap
		else
			return nil
		end #if
	end #search_overlaps
	
	# searching for overlaps on documents found on the internet
	def search_common_region()
		searchMutex = Mutex.new
		threads = []
		for doc in @resultList										# Searchs if there are common region fo revery Document object created
				threads << Thread.new do
					puts "==== Searching overlaps on #{doc.doc_name}===="
					overlap = self.search_overlaps(doc)											# if ovelap = nil no overlaps were found
					if overlap != nil
						searchMutex.lock
							@overlaps << overlap
						searchMutex.unlock
					end #if
				end # do threads
			end #for
			threads.each {|t| t.join}																		# wait the execution of every thread created
		$logger.debug("MasterDocument#fetch_url") {"@Overlaps size: #{@overlaps.size}"}
	end
	
	# displays all the overlaps found
	def display_overlaps()
		i = 1
		j = 1
		print "\n==== Diplay overlaps (display_overlaps)====\n"
		if @overlaps.size > 0
			for item in @overlaps
				if item != nil
				print "\n*********************\n"
				print "MasterDocument ID -> #{item.master_doc.object_id}\n"
				print "MasterDocument name -> #{item.master_doc.doc_name}\n"
				print "CopyDoc ID -> #{item.copy_doc.doc_name}\n"
				print "CopyDoc ID -> #{item.copy_doc.object_id}\n\n"
				puts "Total overlaps: #{item.num_overlaps}"
				puts "Total common words: #{item.tot_words}"
				item.overlaps.each do |x| 
					puts "Overlap #{j} size -> #{x[0]} indexes: Master(#{x[1][0]}, #{x[1][1]}) Copy(#{x[2][0]}, #{x[2][1]})"
					# save a file for test the overlaps (DEBUG CODE)
					filename = "tmp/debug/"+item.master_doc.doc_name+"-"+j.to_s
					open(filename,"w").write("==== master: "+self.get_words(x[1][0], x[0]).to_s+"\n==== copy -> #{item.copy_doc.doc_name}:\n "+item.copy_doc.get_words(x[2][0], x[0]).to_s)
					# end DEBUG CODE
					j += 1
					end
				i += 1
				j = 0
				end
			end #for
			print "\n*********************\n"
		else
			print"=== No overlaps found ===\n\n"
		end #if
		print "\n"
	end #display

	private # private method
	
	# control if the found block hash is the same block 
	# return the size of the found string
	# wlist: word list
	# index_first: index of the first word block in @content
	# index_second: index of the first word block in doc.content
	def block_control(doc, wlist, index_first, index_second)
			wlist_master = get_words(index_first, @@bsize) 			# wlist contains the block
			if (wlist_master == wlist)
				extend_block(doc, wlist_master,index_first, index_second)
				return true
			end #if
			return false 																				# if the found block it's not the same return false (collision)
	end
	
	# Right and left block extension
	# Used to find block that are larger than @@bsize words
	# i: index in @content
	# j: index in @content_2ndfile
	def extend_block(doc, wlist_master, i, j)
		@extended_index = {} 		# hash with key "start_master", "start_copy", "end_master" and "end_copy"
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
		#
		# Da controllare se va oltre il numero massimo già in questo punto
		#
		while (@content[extension_i][0] == doc.content[extension_j][0])
			extension_i += 1
			extension_j += 1
			break if (extension_i > @content.size-1) || (extension_j > doc.content.size-1)
		end #while
		@extended_index["end_master"] = extension_i
		@extended_index["end_copy"] = extension_j
		# debug puts
		if extension_i > i+@@bsize || @extended_index["start_master"] < i
			puts "< extension done >"
		end
	end # extend_block
	
	# return true if @indexTable contains value
	# value: hash of a block of the MasterDocument
	def search_hashValue(value)
		return @indexTable[value][0] != nil
	end #search hash value
	
	# Fetchs URL in the list urlList
	# urlList: contains all the urls find by Google
	# master: MasterDocument pointer
	def fetch_url(master, urlList, search_engine)
		threads = []
		@overlaps = [] 																							# Array that contains all the overlaps found
		puts "==== Create Document objects from url ===="
		while ((url = urlList.get_next) != nil)
			threads << Thread.new do
				if search_engine.kind_of?(GoogleCachedSearchEngine)			# search on cached pages
					begin
						document = WebDocument.new(url)
						@mutex.lock																					# controls access to a shared source
							@resultList << document
						@mutex.unlock
						puts "==== Document Object from #{document.doc_name} created ===="
					rescue StandardError => msg
						$error_logger.error("MasterDocument#fetch_url(Document.new)") {"Document creation failed -> #{msg} #{url}"}
							next 																							# jump to next iteration
					end #exception
				elsif search_engine.kind_of?(GoogleSearchEngine) || search_engine.kind_of?(YahooSearchEngine)		# search on normal pages
						begin	
							document = WebDocument.new(url)
							@mutex.lock																				# controls access to a shared source
								@resultList << document
							@mutex.unlock
							puts "==== Document Object from #{document.doc_name} created ===="
						rescue StandardError => msg
							$error_logger.error("MasterDocument#fetch_url(Document.new)") {"Document creation failed -> #{msg} #{url}"}
							next 																							# jump to next iteration
						end #exception
						# write the error on a log file and continue the execution of program
						#$error_logger.debug("MasterDocument#fetch_url") {"#{url} -> extension: #{extension}"} 	
				end #if
			end # do thread
		end #while
		threads.each {|t| t.join}																		# wait the execution of every thread created
		puts "@resultList size: #{@resultList.size}"								# DEBUG puts
		puts "==== Create Document objects from url OK ===="
		$logger.debug("MasterDocument#fetch_url") {"ResultList complete. Array size: #{@resultList.size}"}
	end # end fetch_url
	
end #class
