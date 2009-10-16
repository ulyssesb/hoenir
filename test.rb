#!/usr/bin/ruby
require 'gdl_parser.tab.rb'
require 'ggp_classes'
require 'prolog_connector'

debugger = ARGV[1] == "true" ? true : false 

gdl_file = File.open(ARGV[0]) rescue nil
gdl_file ||= File.open 'sample_games/tictactoe.kif'
gdl_parser = GameDescriptionLanguage.new

description = gdl_parser.parse(gdl_file.read, debugger)

game = GameDescription.new(description)
debugger

pl_file = File.new('game_description.yap', "w+")
pl_file << game.to_pl
pl_file.close

prolog = PrologConnector.new
game_turn = GameTurn.new(game.inits, prolog)

legals = game_turn.legal_moves(game.legals)
legals.each { |move| puts move.to_pl }



prolog.close
