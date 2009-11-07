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
  ## Insere fatos na base de conhecimento
  def assert(statements)
    # Não é um array
    unless statements.is_a? Array
      prolog.send("assert(" + statements.to_pl + ").\n")
      return 
    end

    statements.each do |statement|
      prolog.send("assert(" + statement.to_pl + ").\n")
    end
  end

  ## Remove fatos
  def retract(statements)
    # Não é um array
    unless statements.is_a? Array
      prolog.send("retract(" + statements.to_pl + ").\n")
      return 
    end
    
    statements.each do |statement|
      prolog.send("retract(" + statement.to_pl + ").\n")
    end
  end

  ## Envia para o prolog uma coleção de cabeçalhos para serem provados
  ## <- Array de Terms
  ## -> Array com os Terms instanciados 
  def proof_terms(terms_array)
    # Envia para o prolog o estado atual do jogo
    assert(@game_state)

    true_facts = terms_array.collect do |term|
      # Pega apenas o cabeçalho dos predicados
      term_head = term.head + ".\n"

      # Envia para o prolog e coleta a resposta
      unified = prolog.send(term_head)
      
      collected_facts = []
      if unified.is_a? TrueClass
        # Não houve unificação, porém a declaração retornou verdadeiro
        # Ex: pai(joao, jose) consta na base de fatos
        collected_facts << Term.new(term.name, term.params)
      elsif not unified.is_a? FalseClass
        # Não retornou falso, houve uma unificação. Guarda o array retornado
        collected_facts = term.val_array_parser(unified)
      end
      collected_facts
    end

    # Remove o estado atual
    retract(@game_state)
    
    # Retorna tudo que foi aceito como verdadeiro no estado atual
    return true_facts.flatten.compact
  end

  public
  def initialize(statements, prolog)
    @game_state = statements
    @prolog = prolog
  end

  ## Calcula quais jogadas são passíveis
  def legal_moves(legals)
    proof_terms(legals)
  end

  ## Calcula qual será o próximo estado, dada uma ação
  def next_state(nexts, action)
    # Insere a ação no prolog
    ## O método _generate_does_ cria um novo Term com o termo _does_ no cabeçalho
    assert(action.generate_does)

    # Cria um novo estado
    new_game_state = GameTurn.new(proof_terms(nexts), @prolog)
    
    # Remove a ação da base
    retract(action.generate_does)

    return new_game_state
  end

  ## Auto explicativa
  def is_terminal?
    # Cria um termo _Terminal_
    terminal = Term.new(:terminal)

    # Como o método sempre retorna um array, tira o valor verdade dele
    answer = proof_terms(terminal)
    if answer.size == 1
      return answer.first
    else 
      return nil
    end
  end
end
