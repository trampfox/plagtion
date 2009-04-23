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

	# size of word blocks used to build the hash table
	@@bsize = 5
	@@table_size = 209503

	def initialize(url)
	
	end #init
	
	def parse(s)
	
	end #parse
	
	def doc_name()
	
	end #doc_name
	
	def to_s()
	
	end #to_s
	
	def num_words()
	
	end #num_words
	
end # class

class MasterDocument < Document

	def initialize(url)
	
	end #init
	
	def get_words(url)
	
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
