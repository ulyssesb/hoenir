# -*- coding: utf-8 -*-
##
## Upper Confidence Bonus applied to Trees
##
class UCTTree
  require 'prolog_connector'
  require 'uct_node'

  ## Limites de tempo para as simulações
  WARMUP_LIMIT = 720
  PLAY_LIMIT = 0.7
  
  attr_accessor :root

  @@prolog = ""
  @@states_hash = {}
  @@simulated_states = []

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
      # Limpa a lista das ações tomadas
      @@simulated_states = []
      
      # Roda uma simulação do jogo. Guarda o último nó
      last_node = simulate_single(@root)
      
      # Recompensa alcançada 
      reward = @@prolog.reward(last_node.state).first
      
      print "UCTTree::Simulate::End of simulation. Reward: "
      puts reward
#      print "UCTTree::Simulate::End of simulation. State: "
#      puts last_node.state

      # Atribui o retorno para os nós do caminho percorrido
      @@simulated_states.each do |state_hash|
        node = @@states_hash[state_hash]
        node.append_return(reward)
      end
    end
  end

  ##
  ## Simula um jogo inteiro
  ##
  def simulate_single(current_node)

    # Desce a árvore até encontrar um nó terminal
    while not @@prolog.is_terminal?(current_node.state)

#      print "UCTTree::SimulateSingle::Current State: "
#      puts current_node.state

      # Visita o nó
      current_node.look_up
      @@simulated_states << current_node.hash    
  
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
    
    return current_node
  end

  ## 
  ## Retorna um par ação/estado. Caso ainda exista alguma ação
  ## não inexplorada, esta será retornada
  ## 
  def choose_simulated_action(node)

    # Tenta encontrar alguma ação que não tenha sido simulada
    unexplored_action = unexplored(node)
    
    unless unexplored_action.nil?
#      print "UCTTree::SimulatedAction:Unexplored Action : "
#      puts unexplored_action

      # Cria um novo nó
      return create_node(node, unexplored_action)
    end

    best_bonus  = 0
    best_node = nil
    best_action = nil
    node.actions.each do |pair|
      children = @@states_hash[pair[:state_hash]]
      bonus = children.bonus(node.visits)
      if bonus >= best_bonus
        best_bonus = bonus
        best_node = children
        best_action = pair[:state_hash]
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
      if not @@states_hash.has_key? pair[:state_hash]
        unexploreds << pair[:action] 
      end
    end
    
    # Retorna nulo não houver ação inexplorada ou seleciona uma randomicamente
    if unexploreds.empty?
      return nil
    else
      return unexploreds.choice
    end
  end

  ## 
  ## Cria um novo nó apartir do nó atual
  ##
  def create_node(current, unexplored_action)
    # Realiza a ação não explorada e calcula o próximo estado
    new_state = @@prolog.next(current.state, unexplored_action)
    
    # Gera um novo nó
    new_node = UCTNode.new(new_state)

    current.set_state_action(unexplored_action, new_node.hash)
    @@states_hash[new_node.hash] = new_node
    
    return new_node
  end
end
