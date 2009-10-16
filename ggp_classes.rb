# -*- coding: utf-8 -*-
require 'gdl_classes'

class GameDescription
  attr_accessor :statements, :inits, :goals, :predicates
  attr_accessor :nexts, :terminals, :players, :legals

  def initialize(description)
    @statements = []
    @predicates = []
    @terminals = []
    @players = []
    @legals = []
    @inits = []
    @goals = []
    @nexts = []

    description.each do |term|
      case term.name
      when :init
        # Remove o term 'init' do começo
        @inits << term.params.first
      when :goal
        @goals << term
      when :next
        @nexts << term
      when :terminal 
        @terminals << term
      when :role
        @players << term
      when :legal 
        @legals << term
      else 
        if term.is_a? Predicate
          @predicates << term
        elsif term.is_a? Term
          @statements << term
        end
      end
    end
  end

  # Gera a string com os predicados e as declarações (sem os inits)
  def to_pl
    string = [@players, @statements, @predicates, 
              @nexts, @goals, @terminals, @legals].map do |item|
      item.map{|term| term.to_pl }
    end
    string.map!{ |i| i.map!{ |term| term << '.'}}
    string.join "\n"
  end
  
end


class GameTurn
  attr_accessor :game_state, :prolog

  private
  ## Insere o estado atual na base de fatos
  def assert_statements
    @game_state.each do |statement|
      prolog.send("assert(" + statement.to_pl + ").\n")
    end
  end

  # Remove o estado atual
  def retract_statements
    @game_state.each do |statement|
      prolog.send("retract(" + statement.to_pl + ").\n")
    end
  end

  public
  def initialize(statements, prolog)
    @game_state = statements
    @prolog = prolog
  end

  ## Calcula quais jogadas são passíveis
  def legal_moves(legals)
    
    # Envia para o prolog o estado atual do jogo
    assert_statements

    legal_moves = legals.collect do |move|
      move_statement =  move.head + "." + "\n"
      unified = prolog.send(move_statement)
      
      partial_moves = []
      # A declaração retornou verdadeira, é uma jogada válida
      if unified.is_a? TrueClass
        partial_moves << Term.new(move.name, move.params)
      # Se não retornou falso é um vetor com as valorações
      elsif not unified.is_a? FalseClass
        partial_moves = move.val_array_parser unified
      end
      partial_moves
    end
    
    # Retira o estado atual
    retract_statements
    return legal_moves.flatten.compact
  end
end
