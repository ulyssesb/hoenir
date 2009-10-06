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
        @inits << term
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
    string = [@players, @statements, @predicates, @nexts, @goals, @terminals].map do 
      |item|
      item.map{|term| term.to_pl }
    end
    string.map!{ |i| i.map!{ |term| term << '.'}}
    string.join "\n"
  end
  
end


class GameTurn
  attr_accessor :game_state, :prolog

  def initialize(statements, prolog)
    @game_state = statements
    @prolog = prolog
  end

  def legal_moves(legals)
    legals.each do |move|
      puts move.to_pl
    end
  end
end
