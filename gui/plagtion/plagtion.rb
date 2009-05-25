#!/usr/bin/env ruby
#
# This file is gererated by ruby-glade-create-template 1.1.4.
#
require 'libglade2'

class PlagtionGlade
  include GetText

  attr :glade
  
  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, "UTF-8")
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
    
  end
  
  def on_quit1_activate(widget)
    puts "on_quit1_activate() is not implemented yet."
  end
  def on_exitButton_clicked(widget)
    puts "on_exitButton_clicked() is not implemented yet."
  end
  def on_about1_activate(widget)
    puts "on_about1_activate() is not implemented yet."
  end
  def on_mainWindow_delete_event(widget, arg0)
    puts "on_mainWindow_delete_event() is not implemented yet."
  end
  def on_detectButton_clicked(widget)
    puts "on_detectButton_clicked() is not implemented yet."
  end
end

# Main program
if __FILE__ == $0
  # Set values as your own application. 
  PROG_PATH = "plagtion.glade"
  PROG_NAME = "YOUR_APPLICATION_NAME"
  PlagtionGlade.new(PROG_PATH, nil, PROG_NAME)
  Gtk.main
end
