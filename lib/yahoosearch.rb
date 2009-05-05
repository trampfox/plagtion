#!/usr/bin/env ruby
require 'ysearch'



class YahooSearchEngine # < SearchEngine

  def initialize()
    @language='it'          # only italian pages
    @app_id = 'YahooDemo'   # this works, but plase use your id
  end

  def search(wlist,n)
    # create query
    query = wlist.join(" ")
    obj = WebSearch.new(@app_id, query, 'all', n)
    obj.set_language(@language)
    # get the results -- returns an array of hashes
    results = obj.parse_results
    results.map {|r| r['Url']}   # get url  
   end

end


ys = YahooSearchEngine.new()
list = ys.search(ARGV,5)
puts list

