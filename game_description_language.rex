class GameDescriptionLanguage
macro 
    AXIOM [[:alnum:]\?\+\-\_\#\|\<\>]+
    BLANK \s+
rule
    or{BLANK}       {[:OR,    text.strip]}    
    role{BLANK}     {[:ROLE,  text.strip]}    
    init{BLANK}     {[:INIT,  text.strip]}    
    true{BLANK}     {[:TRUE,  text.strip]}    
    does{BLANK}     {[:DOES,  text.strip]}    
    next{BLANK}     {[:NEXT,  text.strip]}    
    legal{BLANK}    {[:LEGAL, text.strip]}    
    goal{BLANK}     {[:GOAL,  text.strip]}    
    not{BLANK}      {[:NOT,   text.strip]}    
    terminal{BLANK} {[:TERMINAL, text.strip]}    
    distinct{BLANK} {[:DIST,     text.strip]}    
    
    <= {[:RELATION, text]}
    \( {[:OP, text]}
    \) {[:CP, text]}

    {AXIOM}   {[:ATOM, text]}
    {BLANK}   # no action
    ;.*       # comments
end