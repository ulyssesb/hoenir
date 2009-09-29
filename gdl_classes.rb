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

  def to_pl(values_hash=nil)
    return @name.to_s if self.is_atom?

    # Caso seja uma variável e tenha alguma valoração possivel, imprime-a
    if not values_hash.nil? and not values_hash[@name].nil and self.is_var?
      return values_hash[@name]
    end

    # OR(foo, bar) -> (foo;bar)
    return "(#{params[0].to_pl};#{params[1].to_pl})" if @name == :or

    # Prolog nao aceita declaracoes true(foo BAR)
    string = @name == :true ?  "" : "#{@name.to_s}(" 

    @params.each do |param| 
      param_pl = (@params.index(param)+1) == @params.size ? 
               param.to_pl(values_hash) : param.to_pl(values_hash) + ", "
      string << param_pl
    end
    string.concat ")" unless @name.to_s == "true"
    string
  end
end


class Predicate < Term
  attr_accessor :rules

  def initialize(name, params=[], rules=[])
    super(name, params)
    @rules = rules
  end

  def to_pl(values_hash=nil)
    string = params.empty?? "#{@name.to_s}" : "#{@name.to_s}("

    @params.each do |param| 
      param_pl = (@params.index(param)+1) == @params.size ? 
               param.to_pl(values_hash) : param.to_pl(values_hash) + ", "
      string << param_pl
    end
    string.concat ")" unless params.empty?
    string << ":-\n"

    @rules.each do |param| 
      param_pl = (@rules.index(param)+1) == @rules.size ? 
               "\t" + param.to_pl(values_hash) : "\t" + param.to_pl(values_hash) + ",\n"
      string << param_pl
    end

    string
  end
end

