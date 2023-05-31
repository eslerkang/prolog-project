:- [data].

find_shortest_path(Origin, Destination):-
	charger(C1,Origin),
	charger(C2,Destination),
	a_star([[0,C1]],C2,ReversePath),
	reverse(ReversePath, Path),
	write('The best/shortest Path is: '), print_path(Path,Highways),
    write('Highway to be traveled will be: '),print_highways(Highways),!.

/* This message will be shown if the origin or destination were not typed correctly */
find_shortest_path(_,_):- write('There was an error with origin or destination city, please type again').

/*
 * This predicate acts the same as before, but it continues looking for
 * and shows all the paths
 */
find_all(Origin, Destination):-
	charger(C1,Origin),
	charger(C2,Destination),
	a_star([[0,C1]],C2,ReversePath),
	reverse(ReversePath, Path),
	write('A Path was found: '), print_path(Path,Highways),
	write('Highway to be traveled will be: '),print_highways(Highways),fail.
find_all(_,_):- write('That is all!').

a_star(Paths, Dest, [C,Dest|Path]):-
	member([C,Dest|Path],Paths),
	decide_best(Paths, [C1|_]),
	C1 == C.
a_star(Paths, Destination, BestPath):-
	decide_best(Paths, Best),
	delete(Paths, Best, PreviousPaths),
	expand_border(Best, NewPaths),
	append(PreviousPaths, NewPaths, L),
	a_star(L, Destination, BestPath).

decide_best([X],X):-!.
decide_best([[C1,Ci1|Y],[C2,Ci2|_]|Z], Best):-
	nth1(1, Y, C),
	h(C, Ci1, H1),
	h(C, Ci2, H2),
	H1 +  C1 =< H2 +  C2,
	decide_best([[C1,Ci1|Y]|Z], Best).
decide_best([[C1,Ci1|_],[C2,Ci2|Y]|Z], Best):-
	nth1(1, Y, C),
	h(C, Ci1, H1),
	h(C, Ci2, H2),
	H1  + C1 > H2 +  C2,
	decide_best([[C2,Ci2|Y]|Z], Best).


expand_border([Cost,City|Path],Paths):-
	findall([Cost,NewCity,City|Path],
		(road(City, NewCity,_),
		not(member(NewCity,Path))),
		L),
	change_costs(L, Paths).

change_costs([],[]):-!.
change_costs([[Total_Cost,Ci1,Ci2|Path]|Y],[[NewCost_Total,Ci1,Ci2|Path]|Z]):-
	road(Ci2, Ci1, Distance),
	charge(Ci2, Charge),
	XXX is Charge / 80 - Distance,
	write(XXX),
	XXX is Charge / 80 - Distacne,
	NewCost_Total is Total_Cost + Distance + Charge,
	NewCost_Total =< 1000,
	change_costs(Y,Z).
change_costs([[Total_Cost,_,_|_]|Y],Z):-
	change_costs(Y,Z).


print_path([Cost],[]):- nl, write('The total cost of the path is: '), write(Cost), write(' kilometers'),nl.
print_path([City,Cost],[]):- charger(City, Name), write(Name), write(' '), nl, write('The total cost of the path is: '), write(Cost), write(' kilometers'),nl.
print_path([City,City2|Y],Highways):-
	charger(City, Name),
	highway(City,City2,Highway),
	append([Highway],R,Highways),
	write(Name),write(', '),
	print_path([City2|Y],R).

print_highways([X]):- write(X), nl, nl.
print_highways([X|Y]):-
	write(X),write(' - '),
	print_highways(Y).