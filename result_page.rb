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
  def initialize(url, cachedURL, title, page)
    @url = url
    @cachedURL = cachedURL
    @title = title
		# @@count: number of ResultPage object
		@@count = @@count+1
		# integers indexes list (M elements). Each index points to the begin of the word block
		# One for every ResultPage
		@indexTable = Array.new(M) {Array.new}
		# download the result
		self.download_page
  end

	# test method
	def to_s
		return "Title : #{@title}"
	end 
	
	def download_page
		if (@cachedURL.kind_of?(URI::HTTP))
			# puts @cachedURL.inspect
			# only_text page version
			@cachedURL.query += "&gl=it&strip=1"
=begin
			#-> old code
			doc = Hpricot(open(@cachedURL))
			text = doc.at('body')
			file = File.new("./tmp/#{@@count} - #{@title[0,5]}", "w")
			if (text != nil)
				@content = text.to_plain_text.split(/\W+/)
				#puts @content
			end
			# -> end old code
=end
		#-> new code
		textdoc = htmlfile2text(@cachedURL)
		textdoc
		# -> end new code
		file = File.new("./tmp/#{@@count} - #{@title[0,5]}", "w")
		file.puts textdoc
=begin elimina accentate in questo modo 
		# remove white spaces and other special character
		file.puts textdoc.split(/\W+/) 
=end
		file.close

		if (@content != nil)		
				#puts "=== blockHash ResultPage==="
				i = 0
				j = BLOCK_SIZE-1
				while i < @content.length-1
					# i is the index of the first word 
					blockhash(@content[i..j], i)
					i = j+1
					j = j+BLOCK_SIZE
				end # while
				#puts "=== blockHash ResultPage end ==="
				#puts @indexTable
		end # @content if
=begin
			note:
			@content OK -> contiene tutte le parole prese dal body della pagina
			#@content.each {|x| file.write(x+" ")}
=end
			#file.close
		end # @cachedURL if
	end # method 
	
	#private method of the class
  private
  def blockhash(a, pos)
     hasharray = Array.new(0)
     sum = 0
     i = 0	
     for x in a
        hasharray << x.hash * P**i
        i = i+1
     end
     hasharray.each {|elem| sum = sum + elem}
     @indexTable[sum % M] << pos # posizione della prima parola con un dato hash
  end
	
end # class


=begin

Metodi da fare:
- Ricerca similarità tra testo in input e obj ResultPage

Domande:
- Ricerca (algo Rabin Karp) : elevazione a potenza per i vari blocchi (come procede)

=end
