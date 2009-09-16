

class Term
  attr_accessor :name, :args

  def initialize(name, args=[])
    @name = name.index("?") == 0 ? name.gsub(/^\?/,'').upcase.to_sym : name.to_sym
    @args = args.nil?? [] : args
  end

  def arity
    @args.size
  end

  def is_atom?
    (@args.empty?) ? true : false
  end

  def is_var?
    @name.to_s == @name.to_s.upcase ? true : false
  end

  def to_pl
    if self.is_atom? and not self.is_var?
      return "\'#{@name.to_s}\'"
    elsif self.is_atom?
      return @name.to_s
    end

    # Prolog nao aceita declaracoes true(foo BAR)
    string = @name.to_s == "true"?  "" : "#{@name.to_s}(" 
    @args.each do |arg| 
      arg_pl = (@args.index(arg)+1) == @args.size ? 
               arg.to_pl : arg.to_pl + ", "
      string << arg_pl
    end
    string.concat ")" unless @name.to_s == "true"
    string
  end
end


class Predicate < Term
  attr_accessor :rules

  def initialize(name, args=[], rules=[])
    super(name, args)
    @rules = rules
  end

  def to_pl
    string = args.empty?? "#{@name.to_s}" : "#{@name.to_s}("

    @args.each do |arg| 
      arg_pl = (@args.index(arg)+1) == @args.size ? 
               arg.to_pl : arg.to_pl + ", "
      string << arg_pl
    end
    string.concat ")" unless args.empty?
    string << ":-\n"

    @rules.each do |arg| 
      arg_pl = (@rules.index(arg)+1) == @rules.size ? 
               "\t" + arg.to_pl : "\t" + arg.to_pl + ",\n"
      string << arg_pl
    end

    string
  end
end  
