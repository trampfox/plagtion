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

# PlagTion Version 0.0.1

require 'rubygems'
require 'gscraper'
require 'document'
require 'overlap'
require 'net/http'
require 'hpricot'
require 'open-uri'
require 'miohtml'
require 'url_manager'


NUM_OF_PAGE = 1
# costant used for Bentley McIlroy algorithm
P = 1211 
#M = 209503

def main()
	doc = MasterDocument.new("./test/Ruby2Java.pdf")	
end # main

main()

=begin

call external program
a = `ls`
a.each {|x| puts x}

=end
