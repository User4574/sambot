parse_user(User) ->
	[PUser, _] = string:tokens(User, "!"),
	PUser.

parse_notation(L) ->
	{X, Y} = string:to_integer(L),
	if
		X =:= error ->
			parse_notation_d(1, L);
		X > 1000 ->
			{error, high_x};
		true ->
			parse_notation_d(X, Y)
	end.

parse_notation_d(X, [100|T]) ->
	{Y, _} = string:to_integer(T),
	random:seed(now()),
	if
		Y =:= error ->
			{error, no_y};
		Y < 1 ->
			{error, low_y};
		true ->
			parse_notation_y(X, Y, [])
	end;
parse_notation_d(_, _) ->
	{error, no_d}.

parse_notation_y(0, _, L) ->
	{ok, L};
parse_notation_y(X, Y, L) ->
	parse_notation_y(X-1, Y, [random:uniform(Y) | L]).

makeroll(N) ->
	{S, R} = parse_notation(N),
	if
		S =:= error ->
			return_bad(R);
		true ->
			return_good(R, "Roll(s):")
	end.

makevs(N) ->
	{S, R} = parse_notation("d100"),
	if
		S =:= error ->
			return_bad(R);
		true ->
			D = hd(R) - 1,
			if
				D =:= 0 -> 
					E = [48, 48];
				true ->
					E = itoa(D)
			end,
			{M, _} = string:to_integer(N),
			if
				D =< M andalso hd(E) =:= hd(tl(E)) ->
					"Roll: " ++ E ++ " against " ++ N ++ ". Critical success by " ++ itoa(M - D) ++ ". " ++ itoa((M - D) div 10) ++ " margin(s) of success.";
				D =< M ->
					"Roll: " ++ E ++ " against " ++ N ++ ". Success by " ++ itoa(M - D) ++ ". " ++ itoa((M - D) div 10) ++ " margin(s) of success.";
				hd(E) =:= hd(tl(E)) ->
					"Roll: " ++ E ++ " against " ++ N ++ ". Critical failure by " ++ itoa(D - M) ++ ". " ++ itoa((D - M) div 10) ++ " margin(s) of failure.";
				true ->
					"Roll: " ++ E ++ " against " ++ N ++ ". Failure by " ++ itoa(D - M) ++ ". " ++ itoa((D - M) div 10) ++ " margin(s) of failure."
			end
	end.

makecoin() ->
	random:seed(now()),
	C = random:uniform(2),
	if
		C =:= 1 -> "Heads.";
		true -> "Tails."
	end.

return_bad(high_x) ->
	"Too many dice.";
return_bad(no_d) ->
	"Badly formed expression: no d found.";
return_bad(no_y) ->
	"Badly formed expression: no value found.";
return_bad(low_y) ->
	"Badly formed expression: value must be > 0".

return_good([H], S) ->
	S ++ " " ++ itoa(H) ++ ".";
return_good(L, S) ->
	return_good(L, lists:sum(L), S).
return_good([], T, S) ->
	S ++ ". Total: " ++ itoa(T) ++ ".";
return_good([H|T], L, S) ->
	return_good(T, L, S ++ " " ++ itoa(H)).

itoa(Value) ->
	integer_to_list(Value).

recombine(L) -> recombine(L, "").
recombine([], L) -> L;
recombine([H], L) -> L ++ H;
recombine([H|T], L) -> recombine(T, L ++ H ++ " ").

select_salutation(User) ->
	List = ?salutations,
	Index = random:uniform(length(List)), 
	lists:nth(Index, List) ++ ", " ++ User ++ "!". 
