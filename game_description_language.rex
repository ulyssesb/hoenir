class GameDescriptionLanguage
macro 
    AXIOM [[:alnum:]\?\+\-\_\#\|\<\>]+
    BLANK \s+
rule
    or{BLANK}       {[:OR,    text]}    
    role{BLANK}     {[:ROLE,  text]}    
    init{BLANK}     {[:INIT,  text]}    
    true{BLANK}     {[:TRUE,  text]}    
    does{BLANK}     {[:DOES,  text]}    
    next{BLANK}     {[:NEXT,  text]}    
    legal{BLANK}    {[:LEGAL, text]}    
    goal{BLANK}     {[:GOAL,  text]}    
    not{BLANK}      {[:NOT,   text]}    
    terminal{BLANK} {[:TERMINAL, text]}    
    distinct{BLANK} {[:DIST, text]}    
    
    <= {[:RELATION, text]}
    \( {[:OP, text]}
    \) {[:CP, text]}

    {AXIOM}   {[:ATOM, text]}
    {BLANK}   # no action
    ;.*       # comments
end