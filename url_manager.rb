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


class UrlManager

	def initialize
		@urlList = [] # list of URL found by searching 
	end #init
	
	# add the urls that are in the list lis
	# the urls are URI::HTTP object
	def add_urls(lis)
		begin
			for url in lis
				if !@urlList.include?(url) # add the url only if isn't already in the list
					# sometimes the url doesn't contain the query part (it must be escluded if nil)
					puts url
					#puts "url.host: #{url.host} url.path: #{url.path} url.query: #{url.query}"
					completeUrl = "http://"+url.host+url.path
					if url.query != nil
						completeUrl += "?"+url.query
					end
					@urlList << completeUrl
					$logger.info "http://#{url.host+url.path}?#{url.query} added"
				else
					$logger.info "#{url} is already present in the list"
				end #if
			end #for
		rescue NoMethodError  # first run, urlList = nil
			@urlList[0] = "http"+url.host+url.path+"?"+url.query
			$logger.info "http://#{url.host+url.path}?#{url.query} added"
		end #rescue
	end #add_urls
 	
 	# get the next url to fetch from the list @urlList
	def get_next()
		last = @urlList.size-1 # get last item index
		if last >= 0
			item = @urlList.fetch(last) # get last item
			@urlList.delete_at(last) # deleting last item
			return item 
		else
			return nil
		end #if
	end #get_next

	
end # class 
