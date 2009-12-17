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


class GameState
  # Step-size Parameter
  STEP_SIZE = 0.9

  attr_accessor :statements
  @@rewards= Hash.new
  @@game   = ""
  @@prolog = ""

  private
  ## Prova um termo ou um array de termos
  def prove(query)
    # Envia para o prolog o estado atual
    @@prolog.assert(@statements)

    values = []
    if query.is_a? String
      values = @@prolog.send(query + ".\n")
    else
      query.each do |term|
        answer = @@prolog.send(term + ".\n")
        values << unify(term, answer)
      end
    end

    # Remove o estado atual
    @@prolog.retract(@statements)

    if values.is_a? Array
      return values.flatten
    else 
      return values
    end
  end

  public
  def initialize(statements, game=nil, prolog=nil)
    @@game = game unless game.nil?
    @@prolog = prolog unless prolog.nil?
    @statements = statements
  end

  ## Encontra as jogadas possíveis no estado atual
  def legals

    moves = []
    unified = prove(@@game.legals)
    # Retira o "legal()" e poe um "does()"
    unified.each {|new_move| moves << pack(unpack(new_move), "does") }
    
    return moves
  end

  ## Cria um novo estado depois de executar uma ação
  def next(action)
    @@prolog.assert(action)

    new_state = []
    unified = prove(@@game.nexts)
    unified.each { |new| new_state << unpack(new)}

    @@prolog.retract(action)

    return GameState.new(new_state)
  end
  
  ## Auto explicativa
  def is_terminal?
    query = "terminal"
    answer = prove(query)

    return answer
  end

  ## Hash MD5 do estado
  def md5
    Digest::MD5.hexdigest(@statements.to_s).to_sym
  end

  ## Faz um sort nas ações possíves e escolhe uma ao acaso
  def random_choice
    possibles = self.legals
    possibles = possibles.sort_by { rand }
    possibles.first
  end
  
  ## Escolhe a melhor ação usando o método de Monte Carlo.
  def choose

    # Calcula os movimentos legais no estado atual
    actions = self.legals

    # Faz um random no array
    actions = actions.sort_by { rand }

    # Guarda o estado gerado pela ação 
    neighbors = []

    for i in 0..(actions.length/2 - 1)
      action = actions[i]

      # Simula um jogo a partir do novo estado
      # Cada jogo simulado atualiza a tabela de estados/rewards
      neighbor = self.next(action)
      neighbor.simulate

      neighbors[i] = neighbor
    end

    # Escolhe a ação com maior recompensa
    max = {:index =>0, :reward => 0}
    actions.each_with_index do |action, index|
      neighbor = neighbors[index].nil?? self.next(action) : neighbors[index]

      if @@rewards.has_key? neighbor.md5
        if @@rewards[neighbor.md5] > max[:reward]
          max[:index] = index
          max[:reward] = @@rewards[neighbor.md5]
        end
      end
    end

    actions[max[:index]]
  end

  ## Simula jogadas aleatórias até atingir o fim do jogo
  def simulate

    # Se não é o estado final, simula até atingi-lo
    unless self.is_terminal?

      # Simula uma ação aleatória para o próximo estado
      action = self.random_choice
      random = self.next(action)
      puts action
      puts random.statements

      random.simulate
      
      # Calcula a recompensa
      estimate_reward(random.md5)

    else
      # Descobre a pontuação atingida
      query = "goal(Player, Score)"
      scores = prove(query)
      max = 0

      # Seleciona apenas o maior, caso haja mais de um
      if scores.first.is_a? String
        score = scores.last.to_i
        max = score if score > max
      else
        scores.each do |score_string| 
          puts score_string
          
          score = score_string.scan(/\d+/).first.to_i
          max = score if score > max
        end
      end
      # Guarda a recompensa
      @@rewards[self.md5] = max
    end
  end

  # Assume que se o estado não foi visitado a chance de vencer é sempre de 50%
  # V(t) = V(t) + sp*(V(t+1) - V(t))
  def estimate_reward(last)

    # Estado nunca foi visitado
    unless @@rewards.has_key? self.md5
      @@rewards[self.md5] = 0.5 - STEP_SIZE*(@@rewards[last] - 0.5)
    
    else
      # Se já foi visitado só atualiza o valor se ele for maior
      old = @@rewards[self.md5]
      new = old - STEP_SIZE*(@@rewards[last] - old)
      @@rewards[self.md5] = new if new > old
    end
  end
end
