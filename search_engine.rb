#       search_engine.rb
#       
#       Copyright 2009 Davide Monfrecola <davide.monfrecola@gmail.com>
#       
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.

# search on NUM_OF_SEARCH random text block from the input document

class SearchEngine

	# block: text block to search
	# index: position of the first word of the block
	def initialize(obj_ref, wlist, bsize)
		@wlist = wlist
		@bsize = bsize
		@doc_ref = obj_ref
		@searchString = []
		@tmpList = [] # temp URL list
		@urlManager = UrlManager.new()
	end #init

	def search(num_of_pages)
		randomBlock = []
		NUM_OF_SEARCHS.times do  # take random indexes from wlist
			randomBlock << rand(@wlist.length)
		end
		for index in randomBlock
			@searchString << @doc_ref.get_words(index, @bsize)
		end #for
		puts "searchString -> #{@searchString}"  # test output
	end
	
end #class

class GoogleSearchEngine < SearchEngine
	
		def initialize(obj_ref, wlist, bsize)
			super(obj_ref, wlist, bsize)
		end #init
		
		def search(num_of_pages)
			super(num_of_pages)
			for query in @searchString
				puts "=== query -> #{query} ==="
				q = GScraper::Search.query(:query => query)
				for i in 1..NUM_OF_PAGES
					q.each_on_page(i) do |result|
				#puts "=== Array Index #{index/BLOCK_SIZE} ===" TEST
					@tmpList << result.url
					end # do
				end #for
			end # for
			@urlManager.add_urls(@tmpList)
		end #search
		
end #class

class GoogleCachedSearchEngine < GoogleSearchEngine

	def initialize(obj_ref, wlist, bsize)
		super(obj_ref, wlist, bsize)
	end #init
		
	def search(num_of_pages)
		super(num_of_pages)
		for query in @searchString
				puts "=== query -> #{query} ==="
				q = GScraper::Search.query(:query => query)
				for i in 1..NUM_OF_PAGES
					q.each_on_page(i) do |result|
				#puts "=== Array Index #{index/BLOCK_SIZE} ===" TEST
					@tmpList << result.url+"&gl=it&strip=1"
					end # do
				end #for
			end # for
			@urlManager.add_urls(@tmpList)
			return @urlManager
	end #search
		
end #class

class YahooSearchEngine < SearchEngine

end #class
