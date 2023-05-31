:- dynamic tab/1.
:- [path].

tab(0) :- !.
tab(X) :- X \== 0, write('\x2001'), Y is X-1, tab(Y).

empty_queue([]).
enqueue(E, [], [E]).
enqueue(E, [H|T], [H|Tnew]) :- enqueue(E, T, Tnew).
dequeue(E, [E|T], T).

member_queue(Element, Queue) :- member(Element, Queue).
add_list_to_queue(List, Queue, Newqueue) :- append(Queue, List, Newqueue).

empty_stack([]).
stack(Top, Stack, [Top|Stack]).
member_stack(Element, Stack):-member(Element, Stack).
add_list_to_stack(List, Stack, Result):-append(List, Stack, Result).
print_stack(S):-empty_stack(S).
print_stack(S):-stack(E, Rest, S), write(E), write(' '), print_stack(Rest). /*, nl. */

empty_set([]).
/* member_set(E, S) :- member(E, S). */
member_set([State, Parent, _, _, _], [[State, Parent, _, _, _]|_]).
member_set(X, [_|T]) :- member_set(X, T).

delete_if_in_set(_, [], []).
delete_if_in_set(E, [E|T], T):- !.
delete_if_in_set(E, [H|T], [H|T_new]) :- delete_if_in_set(E, T, T_new), !.
add_if_not_in_set(X, S, S) :- member(X, S), !.
add_if_not_in_set(X, S, [X|S]).
union([], S, S).
union([H|T], S, S_new) :- union(T, S, S2),
		       add_if_not_in_set(H, S2, S_new), !.
subset([], _).
subset([H|T], S) :- member_set(H, S),
	              subset(T, S).
intersection([], _, []).
intersection([H|T], S, [H|S_new]) :-	member_set(H, S),
	intersection(T, S, S_new), !.
intersection([_|T], S, S_new) :- intersection(T, S, S_new), !.
set_difference([], _, []).
set_difference([H|T], S, T_new) :- member_set(H, S),
	set_difference(T, S, T_new), !.
set_difference([H|T], S, [H|T_new]) :- set_difference(T, S, T_new), !.

equal_set(S1, S2) :- subset(S1, S2), subset(S2, S1).

writelist([]) :- nl.
writelist([H|T]):- print(H), tab(1),  /* "tab(n)" skips n spaces. */
                   writelist(T).

empty_pq([]).
insert_pq(State, [], [State]) :- !.
insert_pq(State, [H|Tail], [State, H|Tail]) :- enqueue(X, _, State), enqueue(Y, _, H), precedes(X, Y).
insert_pq(State, [H|T], [H|Tnew]) :- insert_pq(State, T, Tnew).
precedes(X, Y) :- X < Y.
insert_list_pq([ ], L, L).
insert_list_pq([State|Tail], L, New_L) :- insert_pq(State, L, L2), insert_list_pq(Tail, L2, New_L).

member_pq(E, S) :- member(E, S).
insert_sort_queue(State, [], [State]).
insert_sort_queue(State, [H | T], [State, H | T]) :-
    precedes(State, H).
insert_sort_queue(State, [H|T], [H | T_new]) :-
    insert_sort_queue(State, T, T_new).

dequeue_pq(First, [First|Rest], Rest).

test :- go('LA', 'DET'), !.

go(StartName, GoalName) :-
	empty_set(Closed_set),
	empty_pq(Open),
	charger(Start, StartName),
	charger(Goal, GoalName),
	(h(Start, Goal, H) ->
		h(Start, Goal, H); h(Goal, Start, H)),
	T is H/80,
	insert_pq([Start, nil, 0, T, T], Open, Open_pq),
	path(Open_pq, Closed_set, Goal, 240).

path(Open_pq, _, _, _) :-
	empty_pq(Open_pq),
	write('Path searched, no solution found.').

path(Open_pq, Closed_set, Goal, L) :-
	dequeue_pq([State, Parent, _, _, _], Open_pq, _),
	State = Goal,
	write('The solution path is: '), nl,
	printsolution([State, Parent, _, _, _], Closed_set).

path(Open_pq, Closed_set, Goal, L) :-
	dequeue_pq([State, Parent, G, H, F], Open_pq, Rest_open_pq),
	write('Selected for Visit: '),
	print(State), nl,
        get_children([State, Parent, G, H, F],
		Rest_open_pq, Closed_set, Children, Goal, L),
	insert_list_pq(Children, Rest_open_pq, New_open_pq),
	union([[State, Parent, G, H, F]], Closed_set, New_closed_set),
	write('New_open_pq: '),
	print_stack(New_open_pq), nl,
	write('New_closed_set: '),
	writelist(New_closed_set), nl,
        path(New_open_pq, New_closed_set, Goal), !.


get_children([State,_,D,_, _], Rest_open_pq, Closed_set, Children, Goal, L) :-
     (bagof(Child, moves([State, _, D, _, _], Rest_open_pq, Closed_set, Child, Goal, L), Children);Children=[]).

moves([State, _, Depth, _, _], Rest_open_pq, Closed_set,
       [Next, State, New_D, H, S], Goal, L) :-
	move(State, Next),
	not(member_pq([Next, _, _, _, _], Rest_open_pq)),
	not(member_set([Next, _, _, _, _], Closed_set)),
	New_D is Depth + 1,
	heuristic(Next, Goal, H),		% application specific
	S is New_D + H. %, write(Next), nl.

printsolution([State, nil, _, _, _], _) :- write(State), nl.
printsolution([State, Parent, _, _, _], Closed_set) :-
	member_set([Parent, Grandparent, _, _, _], Closed_set),
	printsolution([Parent, Grandparent, _, _, _], Closed_set),
	write(State), nl.

move(State, Next) :-
	(path(State, Next, P) -> Path(State, Next, P); Path(Next, State, P)),
