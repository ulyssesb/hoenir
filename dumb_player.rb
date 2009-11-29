#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'gdl_parser.tab.rb'
require 'ggp_classes'
require 'prolog_connector'

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
game_turn = GameTurn.new(game.inits, prolog)

while not game_turn.is_terminal?
  ## Estado atual do jogo
  puts("Game State::")
  game_turn.game_state.each{ |statement| print("#"); puts statement.to_pl }

  ## Jogadas legais
  puts("Legal Moves::")
  legals = game_turn.legal_moves(game.legals)
  legals.each { |move| puts move.to_pl }

  ## Aqui deveria ter alguma coisa pra selecionar a melhor jogada
  best_action = legals.first
  print("Action Choosen::")
  puts(best_action.generate_does.to_pl)

  ## Pega o próximo estado
  game_turn = game_turn.next_state(game.nexts, best_action)
  puts("Next Game State")
  game_turn.game_state.each{ |statement| print("#"); puts statement.to_pl }
end

puts "FIM DE JOGO!"
prolog.close
