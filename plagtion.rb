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

require 'rubygems'
require 'gscraper'
require 'document'
require 'overlap'
require 'net/http'
require 'hpricot'
require 'open-uri'
require 'miohtml'
require 'url_manager'
require 'search_engine'
require 'lib/ysearch'
require 'modules/readers'


NUM_OF_PAGES = 1
NUM_OF_SEARCHS = 2
P = 1211 # costant used for Bentley McIlroy algorithm
BSIZE = 5

class Plagtion
	
	def main()
		$logger.debug "PID: #{$$}" # process number
		puts "== Create MasterDocument =="
		doc = MasterDocument.new("./test/gpl.txt")	# input document
		$logger.info("Plagtion") {"Master Document name: #{doc.doc_name}"}
		"== Create Copy Document =="
		doc2 = Document.new("./test/small_gpl.txt")
		$logger.info("Plagtion") {"Document name: #{doc2.doc_name}"}
		puts "== Search Overlaps =="
		doc.search_overlaps(doc2)
		puts "== Search Overlaps done =="
	end # main


end #class

program = Plagtion.new
program.main()
# close log file
$logger.close

=begin

Domande:
	* Modulo (Plagtion) 
	* Ricerca similarità (overlap)
	* va bene ocntrollo su lettura file?
	
=end
