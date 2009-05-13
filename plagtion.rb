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

# PlagTion Version 0.0.2

require 'modules/plagtion_mod'

=begin
NUM_OF_PAGES = 1
NUM_OF_SEARCHS = 2
P = 1211 # costant used for Bentley McIlroy algorithm
BSIZE = 5
=end
	P = 1211 # costant used for Bentley McIlroy algorithm
	NUM_OF_PAGES = 1
	NUM_OF_SEARCHS = 2

class Plagtion
	
	def main()
		@overlaps = [] # List of Overlap object
		$logger.debug "PID: #{$$}" # process number
		puts "== Create MasterDocument =="
		doc = MasterDocument.new("./test/gpl.txt")	# input document
		$logger.info("Plagtion") {"Master Document name: #{doc.doc_name}"}
		
		# create 2 Document obj for testing the methods
		
		"== Create Copy Document =="
		doc2 = Document.new("./test/small_gpl.txt")
		$logger.info("Plagtion") {"Document name: #{doc2.doc_name}"}
		puts "== Search Overlaps =="
		#overlap = doc.search_overlaps(doc2)
		@overlaps << doc.search_overlaps(doc2) # list of overlap object
		"== Create Copy Document 2 =="
		doc3 = Document.new("./test/small_gpl2.txt")
		$logger.info("Plagtion") {"Document name: #{doc2.doc_name}"}
		puts "== Search Overlaps =="
		#overlap2 = doc.search_overlaps(doc3)
		@overlaps << doc.search_overlaps(doc3) # list of overlap object
		puts @overlaps.size
		print "Do you want see the common region?(y/n): "
		input = gets.chomp
		if input == 'y'
			print "\n-- Display Overlaps --\n"
			display_overlaps()
			print "\n---------------------\n\n"
		else
			puts "don't display common region" 
		end
		puts "=== Goodbye :) ==="
	end # main
	
	def display_overlaps()
		i = 1
		j = 1
		for item in @overlaps
			if item != nil
			print "\n*********************\n"
			print "Document #{i} -> #{item.master_doc.object_id}\n"
			puts "Total overlaps: #{item.num_overlaps}"
			puts "Total common words: #{item.tot_words}"
			item.overlaps.each do |x| 
				puts "Overlap #{j} size -> #{x[0]}"
				j += 1
				end
			i += 1
			j = 0
			end
		end #for
	end #display


end #class

program = Plagtion.new
program.main()
# close log file
$logger.close

