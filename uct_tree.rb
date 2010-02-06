# -*- coding: utf-8 -*-
##
## Upper Confidence Bonus applied to Trees
##
class UCTTree
  require 'prolog_connector'
  require 'uct_node'

  ## Limites de tempo para as simulações
  WARMUP_LIMIT = 15
  PLAY_LIMIT = 0.7
  
  attr_accessor :root

  @@prolog = ""
  @@states_hash = {}
  def initialize(game_description, prolog_connector)
    # Interface GGP com o prolog
    @@prolog = PrologGGPInterface.new(prolog_connector, game_description)

    # Cria o estado inicial
    @root = UCTNode.new(game_description.inits)
    @@states_hash[@root.hash] = @root
  end

  ##
  ## Escolhe a ação com o melhor retorno para o movimento
  ##
  def move
    # Simula os jogos
    simulate(PLAY_LIMIT)
    
    # Escolhe a melhor ação
    next_state = choose_action
    
    @root = next_state
  end

  ##
  ## Escolhe a melhor ação de acordo com o Método de Monte Carlo:
  ## maior média dos retornos obtidos nas simulações
  ##
  def choose_action
    best_avarege = 0
    best_action = nil
    @root.actions.each do |pair|
      children = pair[:node]
      if children.returns > best_avarage
        best_avarege = children.returns
        best_action = pair[:state]
      end
    end
    return @@states_hash[:best_action]
  end


  ##
  ## Warmup: Simulação inicial com um tempo maior. 
  ##
  def warmup
    simulate(WARMUP_LIMIT)
  end

  ##
  ## Fim de jogo?
  ##
  def is_terminal?
    @@prolog.is_terminal?(@root.state)
  end

  ##
  ## Recompensa atingida
  ##
  def reward
    @@prolog.reward(@root.state)
  end

  ##
  ## Simulação com UCB como parâmetro de escolha
  ##
  def simulate(time_limit)
    # Guarda o nó atual e uma lista dos que foram percorridos
    current_node = @root
    
    time_is_over = false
    Thread.new { sleep time_limit ; time_is_over = true }

    # Simula enquanto tem tempo
    while not time_is_over
      
      # Desce a árvore até encontrar um nó terminal
      while not @@prolog.is_terminal?(current_node)
        # Visita o nó
        current_node.look_up
        visited << current_node

        # Primeira visita ao nó
        if current_node.visits == 1
          # Gera os filhos (movimentos legais)
          legals = @@prolog.legals(current_node.state)
          current_node.set_actions(legals)
        end

        # Busca a melhor ação
        next_state = choose_simulated_action(current_node)
        current_node = next_state
      end
      
      # Recompensa alcançada 
      reward = @@prolog.reward(current_node.state)

      # Atribui o retorno para os nós do caminho percorrido
      visited.each do |node_hash|
        node = @@states_hash(node_hash)
        node.append_return(reward)
      end
    end
  end

  ## 
  ## Busca a melhor ação para simulação. Caso ainda exista alguma que 
  ## não tenha sido explorada, esta será retornada
  ## 
  def choose_simulated_action(node)

    # Tenta encontrar alguma ação que não tenha sido simulada
    unexplored_action = unexplored(node)
    
    unless unexplorede_action.nil?
      # Cria um novo nó
      return create_node(node, unexplored_action)
    end
    
    best_bonus  = 0
    best_action = nil
    node.actions.each do |pair|
      children = pair[:node]
      bonus = children.bonus(@visits)
      if bonus > best_bonus
        best_bonus = bonus
        best_action = pair[:state]
      end
    end
    return @@states_hash[:best_action]
  end

  ##
  ## Busca alguma ação que ainda não foi explorada
  ## 
  def unexplored(node)
    unexplored = nil
    node.actions.each do |pair|
      unexplored = pair[:action] if pair[:node].is_nil? 
    end
    return unexplored
  end

  ## 
  ## Cria um novo nó apartir do nó atual
  ##
  def create_node(current, action)
    # Realiza a ação não explorada e calcula o próximo estado
    new_state = @@prolog.next(node.state, unexplored_action)
    
    # Gera um novo nó
    new_node = UCTNode.new(new_state)
    @@states_hash[new_node.hash] = new_node
    
    # Guarda o nó
    node.set_action_node(action, new_node)      
    
    return new_node
  end
end
