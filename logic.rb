class Term
  attr_accessor :name, :args

  def initialize(name, args=[])
    @name = name.to_sym
    @args = args.nil?? [] : args
  end

  def arity
    @args.size
  end

  def is_atom?
    (@args.empty?) ? true : false
  end

  def to_s
    return @name.to_s if self.is_atom?
      
    string = "(#{@name.to_s}"
    @args.each {|arg| string << " "+arg.to_s}
    string << ")"
    string
  end

  def to_pl
    return @name.to_s if self.is_atom? 
      
    string = "#{@name.to_s}("
    @args.each do |arg| 
      unless (@args.index(arg)+1) == @args.size
        string << arg.to_pl + ", "
      else 
        string << arg.to_pl
      end
    end
    string << ")"
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
      unless (@args.index(arg)+1) == @args.size
        string << arg.to_pl + ", "
      else 
        string << arg.to_pl
      end
    end
    unless args.empty?
      string << ")"
    end
    string << ":-\n"


    @rules.each do |arg| 
      unless (@rules.index(arg)+1) == @rules.size
        string << "\t" + arg.to_pl + ",\n"
      else 
        string << "\t" + arg.to_pl + "\n"
      end
    end

    string
  end
end  
