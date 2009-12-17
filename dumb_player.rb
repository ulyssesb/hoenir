#!/usr/bin/ruby
require 'ggp_classes_new'
require 'gdl_parser.tab.rb'
require 'prolog_connector'
require 'profiler'

debugger = ARGV[1] == "true" ? true : false 
gdl_file = File.open(ARGV[0]) rescue nil
gdl_file ||= File.open 'sample_games/tictactoe.kif'
gdl_parser = GameDescriptionLanguage.new

description = gdl_parser.parse(gdl_file.read, debugger)

game = GameDescription.new(description)

pl_file = File.new('game_description.yap', "w+")
pl_file << game.to_pl
pl_file.close
prolog = PrologConnector.new

#Profiler__::start_profile

state = GameState.new(game.inits, game, prolog)
#while not state.is_terminal?
  legals = state.legals
  puts legals

#  action = state.choose
#  printf "Chosen::"
#  puts action
#  state = state.next(action)

  state = state.next(legals.first)
  puts state.statements
#end

#Profiler__::stop_profile
#Profiler__::print_profile($stderr)

puts "Fim"
