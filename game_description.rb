# -*- coding: utf-8 -*-
require 'gdl_classes'
require 'digest/md5'
require 'utils'

class GameDescription
  attr_accessor :inits, :nexts, :players, :legals
  @@description = []

  def initialize(description)
    @players = []
    @legals = []
    @inits = []
    @nexts = []

    # Deep copy
    data = Marshal.dump(description)
    @@description = Marshal.load(data)

    description.each do |term|
      case term.name
      when :init
        parse_term(term.params.first)
        @inits << term.params.first.to_pl 
      when :role
        @players << get_player_name(term)
      when :next
        parse_term(term)
        @nexts << term.head
      when :legal 
        parse_term(term)
        @legals << term.head
      else 
        # Do nothing
      end
    end

    # Remove entradas duplicadas
    @nexts.uniq!
    @inits.uniq!
    @legals.uniq!
  end

  # Retorna apenas o cabeçalho do termo e troca 
  # o nome das variáveis para PARAM1, PARAM2,...,PARAMN
  def parse_term(term)
    term.params.each_with_index do |param, i|
      if param.is_var?
        param.name = "PARAM" + i.to_s 
      else
        parse_term(param)
      end
    end
  end

  # Retira o nome do jogador 
  # role(pname).
  def get_player_name(term)
    return term.params.first.name
  end

  # Gera a string com os predicados e as declarações (sem os inits)
  def to_pl
    string = ""
    @@description.each do |statement|
      if [:goal,:next,:terminal,:role,:legal].include? statement.name or 
          statement.is_a?(Predicate) or statement.is_a?(Term) and 
          not statement.name == :init
        string << statement.to_pl + ".\n"
      end
    end
    return string
  end
end
