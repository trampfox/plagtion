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

# This class contains the information about the input text/file
class InputText
	
  def initialize()
		@content = Array.new(0)
    @buffer = ""
    # integers indexes list (M elements). Each index points to the begin of the word block
		@indexTable = Array.new(M) {Array.new}
		@resultList = Array.new(0) {Array.new}
  end

  # reads the input file
  def readtext(file)
		# array that contains all threads
		threads = []
		i = 0
    j = BLOCK_SIZE - 1
    @buffer = IO.read(file).downcase!
    @content = @buffer.split(/\W+/) # each element of @content is a word
    #puts @content
    #puts "=== blockHash ==="
    while i < @content.length-1
			# i is the index of the first word 
      blockhash(@content[i..j], i)
      i = j+1
      j = j+BLOCK_SIZE
    end # while
    #puts "=== blockHash end ==="
	  # creare vari oggetti ResultPage, uno per ogni blocco
    puts "=== call search private method ==="
	  i = 0
		#while i < 30
	  #while i < @content.length-1
			puts "--- search on block #{i} - #{i+BLOCK_SIZE} ---"
			i = 150
			# one thread per block
			threads << Thread.new() do
				print "run block #{i/BLOCK_SIZE} thread\n"
				search(@content[i..i+BLOCK_SIZE-1].join(" "), i)
			end # thread
			print "exit block #{i/BLOCK_SIZE} thread\n"
			i = i + BLOCK_SIZE
	  #end # while
    puts "=== end search private method ==="
		print "\n=== Waiting for results ===\n"
		threads.each {|thr|  thr.join }
  end #readtext

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

=begin
	search on Google using Gscraper gem
	query: what I'm looking for
	index: first word index
=end 
  def search(query, index)
		array_index = index/BLOCK_SIZE 
		@resultList[array_index] = Array.new(0)
		# index of the list in @resultList. Every block has a list of web result
		# q instance of Query class
		q = GScraper::Search.query(:query => query)
		# getting search result
		puts "=== Text block #{array_index} (array_index))==="
		#puts "=== Top result --> #{q.top_result}"
		puts ""
		# one obj ResultPage for every page 
		# ResultPage contains info from internet
		for i in 1..NUM_OF_PAGE
			q.each_on_page(i) do |result|
				#puts "=== Array Index #{index/BLOCK_SIZE} ===" TEST
				@resultList[array_index] << ResultPage.new(result.url, result.cached_url, result.title, array_index)
			end # do
		end # for
		puts "=== ResultList on page #{array_index} ==="
		puts @resultList[array_index]
	end

end # class InputText


=begin

Metodi da fare: 
- gestione thread
- Gestione eccezioni -> (Es: OpenURI::HTTPError) quando lancio ricerca

=end
