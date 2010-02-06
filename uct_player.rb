#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'game_description'
require 'gdl_parser.tab.rb'
require 'prolog_connector'
require 'profiler'
require 'uct_tree'

def parser_description(file_path, debugger)
  gdl_file = File.open(ARGV[0]) rescue nil
  gdl_file ||= File.open 'sample_games/tictactoe.kif'
  gdl_parser = GameDescriptionLanguage.new

  description = gdl_parser.parse(gdl_file.read, debugger)
  return description
end

def write_yap_file(game)
  pl_file = File.new('game_description.yap', "w+")
  pl_file << game.to_pl
  pl_file.close
end


# Debugger mode (para o prolog)
debugger = ARGV[1] == "true" ? true : false 

# Faz a leitura da descrição do jogo
description = parser_description(ARGV[0], debugger)

# Estrutura a descrição
game_description = GameDescription.new(description)

# Transcreve para prolog
write_yap_file(game)

# Chama o provador de teoremas
prolog = PrologConnector.new

# Cria a árvore de busca
search_tree = UCTTree.new(game, prolog)

# WARMUP!
search_tree.warmup

# Joga até encontrar o estado final
while not search_tree.is_terminal?
  stime=Time.now

  search_tree.move

  etime=Time.now
  print "UCTPlayer::Delay::"
  puts (etime-stime)
end

# Fim de jogo, mostra a recompensa alcançada
print "UCTPlayer::Score::"
puts search_tree.reward
