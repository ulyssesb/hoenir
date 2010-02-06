# -*- coding: utf-8 -*-
##
## UCTNode
## Nó da árvore de busca
##
class UCTNode
  require 'digest/md5'

  attr_accessor :returns, :visits, :actions, :state
  
  ## Parâmetro para o uso do bonus na simulação
  BONUS_USE = 40.0

  def initialize(state)
    @state = state
    @visits = 0
    @returns = 0.0
    
    # Par estado-ação
    @actions = []
  end

  ## Calcula o Bonus
  ##   Bonus = V + C * sqrt (ln(T) / N), onde
  ##   V = média dos retornos obtidos nas simulações
  ##   C = parâmetro de utilização do bonus
  ##   T = Número de simulações que passaram pelo nó pai
  ##   N = Número de visitadas ao nó
  def bonus(total)
    return( @returns + BONUS_USE*Math.sqrt( Math.log(total) / @visits) )
  end

  ## 
  ## Insere mais um retorno na média 
  ##
  def append_return(simulated_return)
    @returns = @returns + (1.0 / @visits)*(simulated_return - @returns)
  end

  ##
  ## Visita o nó
  ##
  def look_up
    @visits = @visits + 1
  end

  ##
  ## Hash MD5 do estado
  ##
  def hash
    return Digest::MD5.hexdigest(@state.to_s).to_sym   
  end
  
  ## 
  ## Guarda os pares de estado-ação
  ##
  def set_actions(legals)
    legals.each do |legal|
      actions << {:action => legal, :state_hash => nil}
    end
  end

  ##
  ## Atualiza a hash de uma ação
  ##
  def set_state_action(action, state_hash)
    actions.each do |pair|
      if pair[:action] == action
        pair[:state_hash] = state_hash
      end
    end
  end
end
