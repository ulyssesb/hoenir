class GameDescriptionLanguage
    
    token ROLE INIT TRUE DOES NEXT LEGAL GOAL ATOM 
    token RELATION OP CP DIST OR TERMINAL NOT

    rule
        target: game_desc { result = val[0] }
        game_desc: roles inits rules
                          { result = [val[0], val[1], val[2]].flatten }

        
        roles: role       { result = val[0] } | 
               roles role { result = [val[0], val[1]].flatten }
        role:  OP ROLE ATOM CP 
                          { result = Term.new(val[1], [Term.new(val[2])]) }
        
        
        inits: init       { result = val[0] } |
               inits init { result = [val[0], val[1]].flatten }
        init:  OP INIT arg_list CP { result = val[2] }

        
        rules:     OP rules_aux CP       { result = val[1] } |
                   OP rules_aux CP rules { result = [val[1], val[3]].flatten }
        rules_aux: statement             { result = val[0] } |
                   relation              { result = val[0] } 

        
        statement: ATOM  arg_list { result = Term.new(val[0], val[1]) } |
                   LEGAL arg_list { result = Term.new(val[0], val[1]) } 
        
        
        relation: RELATION rel_head rel_body 
                  {result = Predicate.new(val[1].name.to_s, val[1].args, val[2])} |
                  RELATION rel_head 
                  { result = Predicate.new(val[1].name, [], val[2]) }
        rel_head: OP NEXT arg_list CP  { result = Term.new(val[1], val[2]) } |
                  term                 { result = val[0] }
        rel_body: term                 { result = [val[0]] } |
                  rel_body term        { result = [val[0], val[1]].flatten }
        

        arg_list: term          { result = [val[0]] } |
                  arg_list term { result = [val[0], val[1]].flatten }

        term: OP TRUE  arg_list CP { result = Term.new(val[1], val[2]) } |
              OP NOT   arg_list CP { result = Term.new(val[1], val[2]) } |
              OP OR    arg_list CP { result = Term.new(val[1], val[2]) } |
              OP DOES  arg_list CP { result = Term.new(val[1], val[2]) } |
              OP ROLE  arg_list CP { result = Term.new(val[1], val[2]) } |
              OP LEGAL arg_list CP { result = Term.new(val[1], val[2]) } |
              OP GOAL  arg_list CP { result = Term.new(val[1], val[2]) } |
              OP DIST  arg_list CP { result = Term.new(val[1], val[2]) } |
              OP ATOM  arg_list CP { result = Term.new(val[1], val[2]) } |
              TERMINAL             { result = Term.new(val[0], val[1]) } |
              ATOM                 { result = Term.new(val[0]) }
        
        
end

---- header

require "#{File.dirname(__FILE__)}/game_description_language.rex"
require "#{File.dirname(__FILE__)}/logic.rb"

---- inner
def parse( str, debugger )
    @yydebug=debugger
    scan_evaluate( str )
    return do_parse
end

---- footer
