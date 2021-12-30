/*map-info
--can have more than one entry to mapSize and startPoint
--values must be positive and above zero
--can only have one of each hazard type. ex.: CAN'T have deathTile(jews,1,1) and deathTile(jews,3,5)
--can have more than one gold spoot*/
mapSize(4,4).
startPoint(1,1).
deathTile(hole,4,2).
deathTile(monster,1,3).
gold(4,4).

/*check if there is an assured path from start point to the gold*/
start :- startPoint(I,J), inMap(I,J), not(deathTile(T,I,J)), safeStepFrom(I,J,[[I,J]],[[I,J]],[[],[],[]]).

/*check if in map*/
inMap(I,J) :- mapSize(M,N), I < M+1, J < N+1, I > 0, J > 0.

/*hazardous Tile*/
danger(I,J,DeathType) :- around(I,J,X,Y), inMap(X,Y), deathTile(DeathType,X,Y).

/*rules for getting adjacend tiles*/
around(I, J, X, Y) :- aroundList(I,J,L), member([X,Y],L).
aroundList(I,J,[[I,A],[B,J],[C,I],[J,D]]) :- A is J+1, B is I+1, C is I-1, D is J-1.

/*rule to add or remove adjacend tiles from lists*/
removeAroundTile(I,J,List,NewL) :- aroundList(I,J,L), remove(L,List,NewL).
addAroundTile(I,J,List,NewL) :- aroundList(I,J,L), append(L,List,NewL).

/*rule to change guess_lists*/
updateHazardLists(I,J,DeathType,SafeList,DeathList,NewSL,NewDL) :- member([DeathType|DeathTiles], DeathList), hasOneItem(DeathTiles), append([],SafeList,NewSL), append([],DeathList,NewDL);
																																	 member([DeathType|DeathTiles], DeathList), remove([[DeathType|DeathTiles]],DeathList,TempDL), addAroundTile(I,J,[],TempDT), remove(SafeList,TempDT,TempDT2),
																																	 										inter(TempDT2,DeathTiles,NewDT), append([DeathType],NewDT,NewDID), add(NewDID, TempDL, NewDL),addAroundTile(I,J,[],TempL),
									 																																	 	append(DeathTiles,TempL,TempSL1), remove(NewDT,TempSL1,TempSL2), append(TempSL2, SafeList, NewSL);
																																	 addAroundTile(I,J,[],TempDT), remove(SafeList,TempDT,NewDT), append([DeathType],NewDT,NewDL), append([],SafeList,NewSL).

/*path checking*/
safeStepFrom(I,J,[_|Path],Irrelevent1,Irrelevent2) :- gold(I,J), inMap(I,J), write("path taken: " + [[I,J]|Path]).
safeStepFrom(I,J,PathTaken,SafeList,DeathList) :-
																						%if we landed on a hazardus tile
																						danger(I,J,DT), updateHazardLists(I,J,DT,SafeList,DeathList,NewSL,NewDL), addAroundTile(I,J,[],Around), inter(Around,NewSL,SafeAround),
																															 random_member([X,Y],SafeAround), inMap(X,Y), safeStepFrom(X,Y,[[X,Y]|PathTaken],[[X,Y]|NewSL],NewDL);
																						%if we landed on a normal tile
																						addAroundTile(I,J,SafeList,NewSL), around(I,J,X,Y), inMap(X,Y), not(member([X,Y],PathTaken)), safeStepFrom(X,Y,[[X,Y]|PathTaken],[[X,Y]|NewSL],DeathList).
																						%if no other path found
																						idk.

/*Tools*/
   %check if somthing is in List
member(X, [X|_]).
member(X, [_|T]):- member(X, T).

   %removes element of TargetsList from another list. i/o: remove(list of what to remove, the list to remove from, edited list)
remove(_, [], []).
remove(TargetsList, [X|Tail], Result):- member(X, TargetsList), !, remove(TargetsList, Tail, Result).
remove(TargetsList, [X|Tail], [X|Result]):- remove(TargetsList, Tail, Result).

   %adds x to list (wont check for dublicates)
add(X,[],[X]).
add(X,[H|T],[H|L]) :- add(X,T,L).

   %appends to lists(removes dublicates)
append([],L,L).
append([H|T],L2,[H|L3])  :-  append(T,L2,L3).

   %intersection of 2 lists
inter([], _, []).
inter([H1|T1], L2, [H1|Res]) :- member(H1, L2),inter(T1, L2, Res).
inter([_|T1], L2, Res) :- inter(T1, L2, Res).

	%see if list is empty
hasOneItem([X|[]]).

random_member(X, List) :- must_be(list, List), length(List, Len), Len > 0, N is random(Len), nth0(N, List, X).
