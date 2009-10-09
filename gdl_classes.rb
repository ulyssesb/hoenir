# -*- coding: utf-8 -*-
class Term
  attr_accessor :name, :params

  def initialize(name, params=[])
    if not name.is_a? Symbol
      @name = name.index("?") == 0 ? name.gsub(/^\?/,'').upcase.to_sym : name.to_sym
    else
      @name = name
    end
    @params = params.nil?? [] : params
  end

  def arity
    @params.size
  end

  def is_atom?
    (@params.empty?) ? true : false
  end

  def is_var?
    @name.to_s == @name.to_s.upcase ? true : false
  end

  def to_pl
    return @name.to_s if self.is_atom?

    # OR(foo, bar) -> (foo;bar)
    return "(#{params[0].to_pl};#{params[1].to_pl})" if @name == :or

    # Prolog nao aceita declaracoes true(foo BAR)
    string = @name == :true ?  "" : "#{@name.to_s}(" 

    @params.each do |param| 
      param_pl = (@params.index(param)+1) == @params.size ? 
               param.to_pl : param.to_pl + ", "
      string << param_pl
    end
    string.concat ")" unless @name.to_s == "true"
    string
  end

  # Recebe um string na forma [[foo,bar], [rab, oof]], onde cada tupla do 
  # vetor é uma possivel valoração para as variáves do termo
  # Retorna os termos instanciados com as _n_ valorações possíveis
  def arr_val_parser(val_array)
    
  end
end


class Predicate < Term
  attr_accessor :rules

  def initialize(head, rules=[])
    if head.is_a? Term
      super(head.name, head.params)
    else
      super(name, params)
    end
    @rules = rules
  end

  def to_pl
    string = params.empty?? "#{@name.to_s}" : "#{@name.to_s}("

    @params.each do |param| 
      param_pl = (@params.index(param)+1) == @params.size ? 
               param.to_pl : param.to_pl + ", "
      string << param_pl
    end
    string.concat ")" unless params.empty?
    string << ":-\n"

    @rules.each do |param| 
      param_pl = (@rules.index(param)+1) == @rules.size ? 
               "\t" + param.to_pl : "\t" + param.to_pl + ",\n"
      string << param_pl
    end

    string
  end
end

