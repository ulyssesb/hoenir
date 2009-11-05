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

% Fecha o socket se receber um 'end_of_file'
term_evaluate(Term, Sin):-
    Term=end_of_file,
    socket_close(Sin).

% Caso alguma coisa de errado...
term_evaluate(Term, Sin):-
    not(call(Term)),
    write(Sin, 'false'),
    write(Sin, '\n'),
    write('YAP::false('),
    write(Term),
    write(')'), nl.

% Avalia o Term e escreve no socket o valor das variáves
term_evaluate(Term, Sin):-
    not(ground(Term)),
    get_vars(Term, Vars),
    setof(Vars, Term, Solution),
    write('YAP::evaluated => '),
    write(Solution),
    write(' % '), nl,
    write(Sin, Solution),
    write(Sin, '\n').

% Chama o predicado
term_evaluate(Term, Sin):-
    call(Term),
    write(Sin, 'true'),
    write(Sin, '\n'),

    write('YAP::true('), 
    write(Term),
    write(')'), nl.

    
%%
%% Programa principal
%%

:- initialization(go).

go:-
    consult('game_description.yap'),
    consult('gdl_prolog_settings'),
    socket('AF_INET',Sock),
    socket_bind(Sock,'AF_INET'(_,43210)),
    socket_listen(Sock,5),
    socket_accept(Sock,Sin),    
    main_loop(Sock, Sin).

   
main_loop(Sock, Sin):-
    not(is_stream(Sin)),
    write('Cloased Socket... Exiting\n'),
    socket_close(Sock).

main_loop(Sock, Sin):-
    write('YAP::Sock ..... OK. Lendo entrada\n'),
    read(Sin, Term),
    write('YAP::Entrada .. OK. Term Evaluate: '),
    write(Term), nl,
    term_evaluate(Term, Sin),
    write('YAP::Goto main_loop\n'),
    main_loop(Sock, Sin).