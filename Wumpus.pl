/*map-info (has to have exactly one entry to mapSize and startPoint) (positions begine from 0)*/
mapSize(4,4).
startPoint(1,1).
hole(1,4).
monster(4,2).
gold(4,4).

/*to check if X is part of a list*/
member(X, [X|_]).
member(X, [_|T]):- member(X, T).

/*fuction to check all adjcened tiles*/
around(X1, Y1, X2, Y2):- X2 is X1, Y2 is Y1-1;
												 X2 is X1, Y2 is Y1+1;
												 Y2 is Y1, X2 is X1-1;
												 Y2 is Y1, X2 is X1+1.

/*check if in map (can be expanded)*/
inMap(X,Y) :- mapSize(T,R), X < T+1, Y < R+1, X > 0, Y > 0.

/*designating map hazardes*/
map(breezy,I,J) :- around(I,J,X,Y), hole(X,Y).
map(stench,I,J) :- around(I,J,X,Y), monster(X,Y).

/*starting point initilization*/
safeAccess(Irrelevent,I,J) :- startPoint(I,J), inMap(I,J), not(monster(I,J)), not(hole(I,J)).

/*path checking*/
safeAccess(HistoryList,I,J) :- inMap(I,J), around(I,J,X,Y), not(member([X,Y],HistoryList)), not(map(breezy,X,Y)), not(map(stench,X,Y)), safeAccess([[I,J]|HistoryList],X,Y).

/*check if there is a assured path from start point to the gold*/
safeWin :- gold(X,Y), safeAccess([],X,Y).
