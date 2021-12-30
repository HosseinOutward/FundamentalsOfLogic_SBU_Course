/*map-info
--has to have exactly one entry to mapSize and startPoint
--values can be anything
--can have more than one gold spoot*/
mapSize(4,4).
startPoint(1,1).
deathTile(hole,4,2).
deathTile(monster,1,3).
gold(4,4).

/*check if there is an assured path from start point to the gold*/
start :- startPoint(I,J), inMap(I,J), not(dead(I,J)), safeStepFrom(I,J,[[I,J]],[[I,J]],[[],[],[]]).

/*rules for getting adjacend tiles*/
aroundList(I,J,[[I,A],[B,J],[C,J],[I,D]]) :- A is J+1, B is I+1, C is I-1, D is J-1.
around(I, J, X, Y) :- aroundList(I,J,L), member([X,Y],L).

/*check if in map*/
inMap(I,J) :- mapSize(M,N), I < M+1, J < N+1, I > 0, J > 0.

/*rule to add or remove adjacend tiles from lists*/
removeAroundTile(I,J,List,NewL) :- aroundList(I,J,L), remove(L,List,TempL).
addAroundTile(I,J,List,NewL) :- aroundList(I,J,L), append(L,List,NewL).

/*hazardous Tile*/
mapHazard(Death,I,J) :- around(I,J,X,Y), inMap(X,Y), deathTile(Death,X,Y).
danger(I,J) :- mapHazard(Hazard,I,J).
dead(I,J) :- deathTile(T,I,J).

/*rule to change guess_lists*/
editGuessLists(I,J,SafeList,[All,Monster,Hole],[NewAll,NewM,NewH]) :- addAroundTile(I,J,All,TempAll), remove(SafeList, TempAll, NewAll), changeGuessList(I,J,monster,SafeList,Monster,NewM), changeGuessList(I,J,hole,SafeList,Hole,NewH).
changeGuessList(I,J,Hazard,SafeList,List,NewL) :- mapHazard(Hazard,I,J), List=[],  addAroundTile(I,J,List,TempL), remove(SafeList, TempL, NewL);
																									mapHazard(Hazard,I,J), aroundList(I,J,TempL), inter(TempL,List,NewL);
																									not(mapHazard(Hazard,I,J)),NewL=List.
guessListMember([X,Y],[All,Monster,Hole]) :- not(member([X,Y],Monster)),not(member([X,Y],Hole)).

/*tile containing gold*/
safeStepFrom(I,J,[_|Path],Irrelevent1,Irrelevent2) :- gold(I,J), inMap(I,J), write("path taken: " + [[I,J]|Path]).

/*path checking (can be upgraded to have more holes and monsters)*/
safeStepFrom(I,J,HistoryList,SafeList,GuessDeath) :-
																						%if we landed on a hazardus tile
																						danger(I,J), editGuessLists(I,J,SafeList,GuessDeath,NewGD), around(I,J,X,Y), inMap(X,Y), guessListMember([X,Y],NewGD), safeStepFrom(X,Y,[[X,Y]|HistoryList],[[X,Y]|SafeList],NewGD);
																						%if we landed on a normal tile
																						not(danger(I,J)), addAroundTile(I,J,SafeList,NewSL), around(I,J,X,Y), inMap(X,Y), not(member([X,Y],HistoryList)), safeStepFrom(X,Y,[[X,Y]|HistoryList],[[X,Y]|NewSL],NewGD).

/*Tools*/
member(X, [X|_]).
member(X, [_|T]):- member(X, T).

remove(_, [], []).
remove(TargetsList, [X|Tail], Result):- member(X, TargetsList), !, remove(TargetsList, Tail, Result).
remove(TargetsList, [X|Tail], [X|Result]):- remove(TargetsList, Tail, Result).

add(X,[],[X]).
add(X,[H|T],[H|L]) :- add(X,T,L).

append([],L,L).
append([H|T],L2,[H|L3])  :-  append(T,L2,L3).

inter([], _, []).
inter([H1|T1], L2, [H1|Res]) :- member(H1, L2),inter(T1, L2, Res).
inter([_|T1], L2, Res) :- inter(T1, L2, Res).
