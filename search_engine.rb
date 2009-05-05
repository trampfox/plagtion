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
		$logger.info("GoogleSearchEngine") {"searchString -> #{@searchString}"}
	end
	
end #class

class GoogleSearchEngine < SearchEngine
	
		def initialize(obj_ref, wlist, bsize)
			super(obj_ref, wlist, bsize)
		end #init
		
		def search(num_of_pages)
			super(num_of_pages)
			for query in @searchString
				$logger.info("GoogleSearchEngine") {"query -> #{query}"}
				q = GScraper::Search.query(:query => query)
				for i in 0...NUM_OF_PAGES
					q.each_on_page(i) do |result|
					@tmpList << result.url
					end # do
				end #for
			end # for
			@urlManager.add_urls(@tmpList)
		end #search
		
end #class

class GoogleCachedSearchEngine < SearchEngine

	def initialize(obj_ref, wlist, bsize)
		super(obj_ref, wlist, bsize)
	end #init
		
	def search(num_of_pages)
		super(num_of_pages)
		for query in @searchString
				$logger.info("GoogleSearchEngine") {"query -> #{query}"}
				q = GScraper::Search.query(:query => query)
				for i in 0...NUM_OF_PAGES
					q.each_on_page(i) do |result|
						cached = result.cached_url
						if (cached.kind_of?(URI::HTTP)) # exclude URI::Generic obj
							(cached.query+="&gl=it&strip=1")
							@tmpList << cached # dovrebbe essere ok
						end #if
					end # do
				end #for
			end # for
			@urlManager.add_urls(@tmpList)
			return @urlManager
	end #search
		
end #class

class YahooSearchEngine < SearchEngine

	def initialize()
    @language='it'          # only italian pages
    @app_id = 'YahooDemo'   # this works, but plase use your id
  end

  def search(wlist,n)
    # create query
    query = wlist.join(" ")
    obj = WebSearch.new(@app_id, query, 'all', n)
    obj.set_language(@language)
    # get the results -- returns an array of hashes
    results = obj.parse_results
    results.map {|r| r['Url']}   # get url  
   end
   
end #class
