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
    write(Sout, 'YAP::TermEvaluate::EOF\n'),
    socket_close(Sin).

% Caso alguma coisa dê errado...
term_evaluate(Term, Sin, Sout):-
    not(call(Term)),

    write(Sin, 'false'),

    write(Sout, 'YAP::TermEvaluate::False('),
    write(Sout, Term),
    write(Sout, ')'), nl(Sout).

% Avalia o Term e escreve no socket o valor das variáves
term_evaluate(Term, Sin, Sout):-
    not(ground(Term)),
    write(Sout, 'YAP::TermEvaluate::FindAwnsers\n'),
    get_vars(Term, Vars),
    setof(Vars, Term, Solution),

    write(Sout, 'YAP::TermEvaluate::Awnsers => '),
    write(Sout, Solution),
    write(Sout, ' % '), nl(Sout),

    write(Sin, Solution).

% Chama o predicado
term_evaluate(Term, Sin, Sout):-
    call(Term),

    write(Sout, 'YAP::TermEvaluate::Call ->'), 
    write(Sout, Term), nl(Sout),

    write(Sin, 'true'),

    write(Sout, 'YAP::TermEvaluate::True('), 
    write(Sout, Term),
    write(Sout, ')'), nl(Sout).

    
%%
%% Programa principal
%%

:- initialization(go).

go:-
    consult('game_description.yap'),
    consult('gdl_prolog_settings'),
    socket('AF_UNIX',Sock),
    socket_bind(Sock,'AF_UNIX'('/tmp/prolog.sock')),
    socket_listen(Sock,5),
    socket_accept(Sock,Sin), 

    %% Abre um arquivo para log
    open('prolog.log', 'write', Sout),
%    open('/dev/stdout', 'write', Sout),
    main_loop(Sock, Sin, Sout).

   
main_loop(Sock, Sin, Sout):-
    not(is_stream(Sin)),
    write(Sout, 'YAP::Main::Socket closed. Exiting.\n'),
    close(Sout),
    socket_close(Sock).

main_loop(Sock, Sin, Sout):-
    write(Sout, 'YAP::Main::Waiting\n'),
%    time(read(Sin, Term)),
    read(Sin, Term),
    write(Sout, 'YAP::Main::Received ->'),
    write(Sout, Term), nl(Sout),
    term_evaluate(Term, Sin, Sout),

    write(Sin, '\n'),
    flush_output(Sin),

    write(Sout, 'YAP::Main::Evaluated\n'),
    main_loop(Sock, Sin, Sout).