#!/usr/bin/ruby
require 'gdl_parser.tab.rb'
require 'ggp_classes'

debugger = ARGV[1] == "true" ? true : false 

gdl_file = File.open(ARGV[0])
gdl_parser = GameDescriptionLanguage.new

description = gdl_parser.parse(gdl_file.read, debugger)

game = GameDescription.new(description)

pl_file = File.new('game_description.yap', "w+")
pl_file << game.to_pl
pl_file.close
