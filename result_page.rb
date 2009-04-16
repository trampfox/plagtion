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
class ResultPage

  @content = ""
  @url = ""
  @cachedURL = ""
  @title = ""
	@only_text = "&gl=it&strip=1"
	@@count = 0
  
=begin
	url: webpage url
	cachedURL: cached webpage url
	title: webpage title
	index: first block word index
=end
  def initialize(url, cachedURL, title, index)
    @url = url
    @cachedURL = cachedURL
    @title = title
		@@count = @@count+1
		self.download_page
  end

	# test method
	def to_s
		return "Title : #{@title}"
	end 
	
	def download_page
		if (@cachedURL.kind_of?(URI::HTTP))
			puts @cachedURL.inspect
			#htmlfile2text(@cachedURL)
			doc = Hpricot(open(@cachedURL))
			file = File.new("./tmp/#{@@count} - #{@title[0,5]}", "w")
			@content = doc.to_plain_text
			file.write(@content.split(/\W+/))
			file.close
		end #if
	end # method 
	
end # class
