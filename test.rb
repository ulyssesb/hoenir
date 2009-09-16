#!/usr/bin/ruby
require 'game_description_language.tab.rb'

debugger = ARGV[1] == "true" ? true : false 

gdl_file = File.open(ARGV[0])
gdl_parser = GameDescriptionLanguage.new

x = gdl_parser.parse(gdl_file.read, debugger)
prolog_string = x.collect { |i| i.to_pl}
prolog_string.map!{ |i| i << '.' }

puts prolog_string
