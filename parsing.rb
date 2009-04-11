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

require 'rubygems'
require 'net/http'
require 'hpricot'
require 'open-uri'

=begin
	def parsing()
		url = "http://www.google.it"
		doc = open(url) { |f| Hpricot(f) }
		file = File.new("out.txt","w")
		file.puts doc.to_plain_text
		file.close
	end
=end

	def parsing()
		doc = Hpricot(open("http://209.85.129.132/search?q=cache:eBgwJnv8jVkJ:www.progettoradis.it/+progetto+radis&hl=it&client=firefox-a&gl=it&strip=1"))
		file = File.new("out.txt", "w")
		file.puts doc.to_plain_text
		file.close
	end

#http://www.galileo.it/crypto/telelavoro/tgpi-11_6.htm
#.each_element( './/text()' ){}.join() per prendere il testo da ogni elemento
parsing
