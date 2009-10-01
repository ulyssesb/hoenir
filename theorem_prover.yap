% []
get_vars([], []).

% [foo, X, Y, non]
get_vars([PredicateName|PredicateVars], VarList):-
    atom(PredicateName), 
    get_vars(PredicateVars, VarList).

% [X, Y, non]
get_vars([Var|PredicateVars], VarList):-
    var(Var),
    get_vars(PredicateVars, OtherVars), 
    lists:append([Var], OtherVars, VarList).

% [foo(X,Y, non), X, Y]
get_vars([SomeListHead|SomeListTail], VarList):-
    get_vars(SomeListHead, ListHeadVars),
    get_vars(SomeListTail, ListTailVars),
    lists:append(ListHeadVars, ListTailVars, VarList).

% foo(X,Y, non)
get_vars(Predicate, VarList):-
    compound(Predicate),
    Predicate=..PredicateList,
    get_vars(PredicateList, VarList).


% Avalia o Term e escreve no socket o valor das variáves
term_evaluate(Term, Sin):-
    not(ground(Term)),
    get_vars(Term, Vars),
    setof(Vars, Term, Solution),
    write(Sin, Solution).

% Chama o predicado
term_evaluate(Term, Sin):-
    call(Term),
    write('+ '), 
    write(Term), nl.
    

%%
%% Programa principal
%%

:- initialization(go).

go:-
    consult('game_description.yap').
%%     socket('AF_INET',Sock),
%%     socket_bind(Sock,'AF_INET'(_,43210)),
%%     socket_listen(Sock,5),
%%     socket_accept(Sock,Sin),    
%%     main_loop(Sin).

   
%% main_loop(Sin):-
%%     write('Sock - OK. Lendo entrada...\n'),
%%     read(Sin, Term),
%%     write('Entrada - OK. term_evaluate\n'),
%%     term_evaluate(Term, Sin),
%%     write('Goto main_loop\n'),
%%     main_loop(Sin).