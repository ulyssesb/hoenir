# -*- coding: utf-8 -*-
require 'gdl_classes'
require 'digest/md5'

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


class GameState
  attr_accessor :state, :prolog, :legals, :nexts, :rewards

  # Step-size Parameter
  @@step_size = 0.9

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
    # Garante que o parametro é um array
    terms_array = [terms_array] unless terms_array.is_a? Array
    
    # Envia para o prolog o estado atual do jogo
    assert(@state)

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
    retract(@state)

    # Retorna tudo que foi aceito como verdadeiro no estado atual
    return true_facts.flatten.compact.uniq
  end

  public
  def initialize(statements, prolog, legals, nexts, rewards=nil)
    # Os estados gerados vem com o predicado 'next', que não pertencem ao estado
    # do jogo. Ex.: next(cell(1,2,1)) -> cell(1,2,1)
    @state = statements.collect{ |state| state.remove_next }.flatten
    @prolog = prolog
    @legals = legals
    @nexts = nexts
    @rewards = rewards.nil?? Hash.new : rewards
  end

  ## Calcula quais jogadas são passíveis
  def legal_moves
    # Chama o provador e retira os estados repetidos
    proof_terms(@legals)
  end

  ## Calcula qual será o próximo estado, dada uma ação
  def next_state(action)
    # Insere a ação no prolog
    ## O método _generate_does_ cria um novo Term com o termo _does_ no cabeçalho
    assert(action.generate_does)

    # Cria um novo estado
    new_state = proof_terms(@nexts)
    new_turn = GameState.new(new_state, @prolog, @legals, @nexts)
    
    # Remove a ação da base
    retract(action.generate_does)

    return new_turn
  end

  ## Auto explicativa
  def is_terminal?
    # Cria um termo _Terminal_
    terminal = Predicate.new(:terminal)

    # Como o método sempre retorna um array, tira o valor verdade dele
    answer = proof_terms(terminal)
    if answer.size == 1
      return answer.first
    elsif answer.empty?
      return false
    else 
      return nil
    end
  end

  ## Hash MD5 do estado
  def md5
    string_array = @state.each {|state| state.to_pl}
    string_to_hash = string_array.to_s
    Digest::MD5.hexdigest(string_to_hash).to_sym
  end

  ## Faz um sort nas ações possíves e escolhe uma ao acaso
  def random_action
    possibles = legal_moves
    possibles = possibles.sort_by { rand }
    possibles.first
  end
  
  ## Escolhe a melhor ação usando o método de Monte Carlo.
  def choose_action

    # Calcula os movimentos legais no estado atual
    actions = legal_moves

    # Faz um random no array
    actions = actions.sort_by { rand }

    # Guarda o estado gerado pela ação 
    neighbors = []

    for i in 0..actions.length/2
      action = actions[i]

      # Simula um jogo a partir do novo estado
      # Cada jogo simulado atualiza a tabela de estados/rewards
      neighbor = next_state(action)
      neighbor.simulate_play

      neighbors[i] = neighbor
    end

    # Escolhe a ação com maior recompensa
    max = {:index =>0, :reward => 0}
    actions.each_with_index do |action, index|
#      debugger
      neighbor = neighbors[index].nil?? next_state(action) : neighbors[index]

      if @rewards.has_key? neighbor.md5
        if @rewards[neighbor.md5] > max[:reward]
          max[:index] = index
          max[:reward] = @rewards[neighbor.md5]
        end
      end
    end

    actions[max[:index]]
  end

  ## Simula jogadas aleatórias até atingir o fim do jogo
  def simulate_play

    # Se não é o estado final, simula até atingi-lo
    unless self.is_terminal?

      # Simula uma ação aleatória para o próximo estado
      action = self.random_action
      puts action.to_pl
      random = self.next_state(action)
      random.simulate_play
      
      # Guarda as recompensas atualizadas
      @rewards = random.rewards

      # Calcula a recompensa
      estimate_reward(random.md5)

    else
      # Descobre a pontuação atingida
      goal = Predicate.new(Term.new(:goal, [Term.new("P"), Term.new("S")]))
      scores = proof_terms(goal)
      max = 0
      
      # Seleciona apenas o maior, caso haja mais de um
      scores.each do |s| 
        puts s.to_pl 
        max =  s.params[1].name.to_i if s.params[1].name.to_i > max 
      end

      # Guarda a recompensa
      @rewards[self.md5] = max
    end
  end

  # Assume que se o estado não foi visitado a chance de vencer é sempre de 50%
  # V(t) = V(t) + sp*(V(t+1) - V(t))
  def estimate_reward(last)

    # Estado nunca foi visitado
    unless @rewards.has_key? self.md5
      @rewards[self.md5] = 0.5 - @@step_size*(@rewards[last] - 0.5)
    
    else
      # Se já foi visitado só atualiza o valor se ele for maior
      old = @rewards[self.md5]
      new = old - @@step_size*(@rewards[last] - old)
      @rewards[self.md5] = new if new > old
    end
  end
end
