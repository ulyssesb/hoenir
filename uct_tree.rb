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
    best_average = 0
    best_node = nil
    @root.actions.each do |pair|
      children = @@states_hash[pair[:state_hash]]
      if children.returns >= best_average
        best_average = children.returns
        best_node = children
      end
    end
    return best_node
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
    time_is_over = false
    Thread.new { sleep time_limit ; time_is_over = true }

    # Simula enquanto tem tempo
    while not time_is_over
      # Guarda o nó atual e uma lista dos que foram percorridos
      current_node = @root
      visited = []

      # Desce a árvore até encontrar um nó terminal
      while not @@prolog.is_terminal?(current_node.state)
        # Visita o nó
        current_node.look_up
        visited << current_node.hash

        # Primeira visita ao nó
        if current_node.visits == 1
          # Gera os filhos (movimentos legais)
          legals = @@prolog.legals(current_node.state)
          current_node.set_actions(legals)
        end

        # Busca a melhor ação
        next_state = choose_simulated_action(current_node)
        current_node = next_state

        print "UCTTree::Simulate::Current State: "
        puts current_node.state

      end
      
      # Recompensa alcançada 
      reward = @@prolog.reward(current_node.state).first
      
      print "UCTTree::Simulate::End of simulation. Reward: "
      puts reward
      print "UCTTree::Simulate::End of simulation. State: "
      puts current_node.state
      
      # Atribui o retorno para os nós do caminho percorrido
      visited.each do |node_hash|
        node = @@states_hash[node_hash]
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
    
    unless unexplored_action.nil?
      # Cria um novo nó
      return create_node(node, unexplored_action)
    end

    best_bonus  = 0
    best_node = nil
    node.actions.each do |pair|
      children = @@states_hash[pair[:state_hash]]
      bonus = children.bonus(node.visits)
      if bonus >= best_bonus
        best_bonus = bonus
        best_node = children
      end
    end
    return best_node
  end

  ##
  ## Busca alguma ação que ainda não foi explorada
  ## 
  def unexplored(node)
    unexploreds = []
    node.actions.each do |pair|
      unexploreds << pair[:action] if pair[:state_hash].nil? 
    end
    
    return unexploreds.choice
  end

  ## 
  ## Cria um novo nó apartir do nó atual
  ##
  def create_node(current, unexplored_action)
    # Realiza a ação não explorada e calcula o próximo estado
    new_state = @@prolog.next(current.state, unexplored_action)
    
    # Gera um novo nó
    new_node = UCTNode.new(new_state)
    @@states_hash[new_node.hash] = new_node
    
    # Guarda o nó
    current.set_state_action(unexplored_action, new_node.hash)
    
    return new_node
  end
end
