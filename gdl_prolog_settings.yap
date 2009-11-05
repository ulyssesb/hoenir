%% Alguns ajustes na descrição em GDL para que o Prolog consiga trabalhar

% DISTINCT Clause
distinct(X, Y):- X \= Y.

% OR Clause
or(X, Y):- 
    call(X) ; call(Y).
or(X, Y, Z):- 
    call(X) ; call(Y) ; call(Z).
or(X, Y, Z, W):- 
    call(X) ; call(Y) ; call(Z) ; call(W).