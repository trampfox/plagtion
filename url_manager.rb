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
	
	def add_urls(lis)
		begin
			for url in lis
				if !@urlList.include?(url)
					@urlList << url
					$logger.info "#{url} added"
				else
					$logger.info "#{url} is already present in the list"
				end #if
			end #for
		rescue NoMethodError  # first run, urlList = nil
			@urlList[0] = url
			$logger.info "#{url} added"
		end #rescue
	end #add_urls
 	
	def get_next()
		last = @urlList.size-1 # last item index
		item = @urlList.fetch(last) # last item
		@urlList.delete_at(last) # deleting last item
		return item
	end #get_next
	
end
