# -*- coding: utf-8 -*-
class Term
  ## Palavras reservadas do prolog
  @@pl_tokens = [:succ, :table]

  attr_accessor :name, :params

  def initialize(name, params=[])
    if name.is_a? String
      @name = name.index("?") == 0 ? name.gsub(/^\?/,'').upcase.to_sym : name.to_sym
    elsif not name.nil? 
      @name = name
    else 
      return nil
    end
    
    # Tratamento para as palavras reservadas do prolog
    # :token => :token__
    @name = ("%s__" % @name).to_sym if @@pl_tokens.include? @name
    
    @params = params.nil?? [] : params
  end

  def arity
    @params.size
  end

  def is_atom?
    @params.empty?
  end

  def is_var?
    @name.to_s == @name.to_s.upcase ? true : false
  end

  ## Operador de igualdade
  def == (other)
#    debugger
    return false if other.nil? or
                    (not self.name == other.name) or 
                    (not self.arity == other.arity)
    self.params.each_with_index do |param, i| 
      return false unless param == other.params[i]
    end
    return true
  end

  def eql? (other)
    self == other
  end

  ## Para a operação uniq
  def hash
    self.to_pl.hash
  end

  def to_pl
    return @name.to_s if self.is_atom?

    # Prolog nao aceita declaracoes true(foo BAR)
    string = @name == :true ?  "" : "#{@name.to_s}(" 

    @params.each_with_index do |param, index|
      param_pl = (index+1) == @params.size ? param.to_pl : param.to_pl + ", "
      string << param_pl
    end
    string.concat ")" unless @name.to_s == "true"
    string
  end

  # Para realizar uma ação, e ser avaliada no cálculo do novo estado, o termo (que
  # supostamente é uma ação) deve ser encapsulado por um  _does_
  def generate_does
    # <- legal(player, action)
    # -> does(player, action)
    if self.name == :legal
      Term.new(:does, self.params)
    else
      Term.new(:does, [self]) 
    end
  end

  # Os estados gerados vem com o predicado 'next', que não pertencem ao estado
  # do jogo. Ex.: next(cell(1,2,1)) -> cell(1,2,1)
  def remove_next
    if self.name == :next
      Term.new(self.params.first.name, self.params.first.params)
    else
      self
    end    
  end


  # Procura nos parametros todas as variáveis. Retorna um array
  def vars
    vars_list = @params.collect do |param|
      if param.is_var?
        param.name
      elsif not param.is_atom?
        param.vars
      end
    end
    vars_list.flatten.compact
  end

  # <- Hash na forma :var => [val1, val2]
  # -> Array com os termos gerados a partir da valoração
  def bind_vars(val_hash)
    # Cria um termo para cada valoração possível
    if self.is_var? and val_hash.has_key? @name
      return val_hash[@name].collect { |val| Term.new val}

    # Copia a si mesmo n vezes, onde n é o número de valorações possíveis
    elsif self.is_atom?
      n = val_hash.first.at(1).length rescue nil
      dumps = []
      n.times { dumps << self.dup } unless n.nil?
      dumps
    else 
      # Coleta as valorações
      binded = @params.collect { |param| param.bind_vars(val_hash) }
      binded = binded.transpose # Transforma em um array [[valA1, valB1...]]
      # Retorna um array com todas as valorações
      return binded.collect { |params| Term.new(@name, params)}
    end
  end

  # Recebe um string na forma [[foo,bar], [rab, oof]], onde cada tupla do 
  # vetor é uma possivel valoração para as variáves do termo
  # Retorna os termos instanciados com as _n_ valorações possíveis
  def val_array_parser(val_array)
    return nil if val_array.nil?

    vars = self.vars

    # Transforma o array 
    # [[valA1, valB1], [valA2, valB2]] em 
    # [[valA1, valA2], [valB1, valB2]] 
    val_array = val_array.transpose

    # Faz a união dos arrays em duplas [var, vals]
    tuples = vars.zip val_array

    # Transforma em uma hash :var => val
    val_hash = {}
    tuples.each { |var, val| val_hash.store var, val }

    # Cria os novos termos
    return self.bind_vars(val_hash)
  end
end


class Predicate < Term
  attr_accessor :rules

  def initialize(head, rules=[])
    if head.is_a? Term
      super(head.name, head.params)
    elsif head.is_a? String or head.is_a? Symbol
      super(head)
    end
    @rules = rules
  end

  ## Operador de igualdade
  def == (other)
    return false unless super(other)
    return false unless self.rules.size == other.rules.size
    self.rules.each_with_index do |rule, i| 
      return false unless rule == other.rule[i]
    end
    return true
  end

  def eql?(other)
    self == other
  end

  ## Para a operação uniq
  def hash
    # Apenas imprime o Termo
    self.to_pl.hash
  end


  # Imprime o cabeçalho do predicado
  def head
    string = @params.empty?? "#{@name.to_s}" : "#{@name.to_s}("
    @params.each_with_index do |param, index| 
      param_pl = (index+1) == @params.size ? param.to_pl : param.to_pl + ", "
      string << param_pl
    end
    string.concat ")" unless @params.empty?
    string
  end

  def to_pl
    string = self.head || ""
    unless @rules.empty?
      string << ":-\n"

      @rules.each_with_index do |param, index| 
        param_pl = (index+1) == @rules.size ? 
                    "\t" + param.to_pl : "\t" + param.to_pl + ",\n"
        string << param_pl
      end
    end
    string
  end
end

