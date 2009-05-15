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
=begin
TO DO: vedere cosa ritornare. Se non trovo OVerlaps è inutile ritornare unoggetto. TOrnare nil e fare controllo
			Da fare nelfile document.rb

=end

class Overlap
	
	def initialize(master, copy)
		@master_doc = master
		@copy_doc = copy
		@overlap = [] # list of overlap regions -> [n, [i,f], [is, fs]]
	end #init
	
	def master_doc()
		return @master_doc
	end
	
	def copy_doc()
		return @copy_doc
	end
	
	def num_overlaps()
		return @overlap.size
	end
	
	# total words in all common regions
	def tot_words()
		tot_words = 0
		@overlap.each {|overlap| tot_words += overlap[0]}
		return tot_words
	end	
	
	# size: size of common region
	def add(size, ext_index)
		@overlap << [size, [ext_index["start_master"], ext_index["end_master"]], [ext_index["start_copy"], ext_index["end_copy"]]]
		$logger.debug("Overlap") {"Overlap region added"}
	end #add
	
	def overlaps()
		return @overlap
	end
	
end #class

