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
term_evaluate(Term, Sin, Sout):-
    Term=end_of_file,
    socket_close(Sin).

% Caso alguma coisa de errado...
term_evaluate(Term, Sin, Sout):-
    not(call(Term)),
    write(Sin, 'false'),
    write(Sin, '\n'),
    write(Sout, 'YAP::false('),
    write(Sout, Term),
    write(Sout, ')'), nl(Sout).

% Avalia o Term e escreve no socket o valor das variáves
term_evaluate(Term, Sin, Sout):-
    not(ground(Term)),
    get_vars(Term, Vars),
    setof(Vars, Term, Solution),
    write(Sout, 'YAP::evaluated => '),
    write(Sout, Solution),
    write(Sout, ' % '), nl(Sout),
    write(Sin, Solution),
    write(Sin, '\n').

% Chama o predicado
term_evaluate(Term, Sin, Sout):-
    call(Term),
    write(Sin, 'true'),
    write(Sin, '\n'),

    write(Sout, 'YAP::true('), 
    write(Sout, Term),
    write(Sout, ')'), nl(Sout).

    
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
    %% Abre um arquivo para log
    open('prolog.log', 'write', Sout),
    main_loop(Sock, Sin, Sout).

   
main_loop(Sock, Sin, Sout):-
    not(is_stream(Sin)),
    write(Sout, 'Cloased Socket... Exiting\n'),
    socket_close(Sock).

main_loop(Sock, Sin, Sout):-
    write(Sout, 'YAP::Sock ..... OK. Lendo entrada\n'),
    read(Sin, Term),
    write(Sout, 'YAP::Entrada .. OK. Term Evaluate: '),
    write(Sout, Term), nl(Sout),
    term_evaluate(Term, Sin, Sout),
    write(Sout, 'YAP::Goto main_loop\n'),
    main_loop(Sock, Sin, Sout).