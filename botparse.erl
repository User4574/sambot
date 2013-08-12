parse_line(Sock, [_,"376"|_]) ->
	lists:foreach(fun(X) -> gen_tcp:send(Sock, "JOIN :" ++ X ++ "\r\n") end, ?channels);

parse_line(Sock, ["PING"|Rest]) ->
        gen_tcp:send(Sock, "PONG " ++ Rest ++ "\r\n");

parse_line(Sock, [User, "JOIN", "#stairs_at_mycenaeOOC" | _]) ->
	irc_send(Sock, "#stairs_at_mycenaeOOC", select_salutation(parse_user(User)));

parse_line(Sock, [User, "PRIVMSG", ?nickname, "&op", Channel | _]) ->
	U = parse_user(User),
	T = lists:member(U, ?oplist),
	if
		T ->
			irc_mode(Sock, Channel, "+o", U),
			irc_send(Sock, U, "Done.");
		true ->
			irc_send(Sock, U, "Unauthorised.")
	end;

parse_line(Sock, [User, "PRIVMSG", ?nickname, "&deop", Channel | _]) ->
	U = parse_user(User),
	T = lists:member(U, ?oplist),
	if
		T ->
			irc_mode(Sock, Channel, "-o", U),
			irc_send(Sock, U, "Done.");
		true ->
			irc_send(Sock, U, "Unauthorised.")
	end;

parse_line(Sock, [User, "PRIVMSG", Channel, "&op" | _]) ->
	U = parse_user(User),
	T = lists:member(U, ?oplist),
	if
		T ->
			irc_mode(Sock, Channel, "+o", U),
			irc_send(Sock, Channel, U ++ ": Done.");
		true ->
			irc_send(Sock, Channel, U ++ ": Unauthorised.")
	end;

parse_line(Sock, [User, "PRIVMSG", Channel, "&deop" | _]) ->
	U = parse_user(User),
	T = lists:member(U, ?oplist),
	if
		T ->
			irc_mode(Sock, Channel, "-o", U),
			irc_send(Sock, Channel, U ++ ": Done.");
		true ->
			irc_send(Sock, Channel, U ++ ": Unauthorised.")
	end;

parse_line(Sock, [User, "PRIVMSG", Channel, "&dibs" | _]) ->
	irc_gen(Sock, "TOPIC", Channel, parse_user(User) ++ " has the stick!");

parse_line(Sock, [User, "PRIVMSG", Channel, "&pass", NewUser | _]) ->
	irc_gen(Sock, "TOPIC", Channel, NewUser ++ " has the stick!"),
	irc_send(Sock, Channel, parse_user(User) ++ " passes the stick to " ++ NewUser ++ ".");

parse_line(Sock, [User, "PRIVMSG", Channel, "&topic" | Message]) ->
	irc_gen(Sock, "TOPIC", Channel, recombine(Message)),
	irc_send(Sock, Channel, parse_user(User) ++ ": Done.");

parse_line(Sock, [User, "PRIVMSG", ?nickname, "&help", "roll" | _]) ->
	irc_send(Sock, parse_user(User), "Simple. &roll <notation>, or &100.");
parse_line(Sock, [User, "PRIVMSG", ?nickname, "&help", "notation" | _]) ->
	irc_send(Sock, parse_user(User), "Currently <number>d<number>.");
parse_line(Sock, [User, "PRIVMSG", ?nickname, "&help" | _]) ->
	irc_send(Sock, parse_user(User), "Be more specific: '&help roll' or '&help notation'.");

parse_line(Sock, [User, "PRIVMSG", Channel, "&help", "roll" | _]) ->
	irc_send(Sock, Channel, parse_user(User) ++ ": Simple. &roll <notation>.");
parse_line(Sock, [User, "PRIVMSG", Channel, "&help", "notation" | _]) ->
	irc_send(Sock, Channel, parse_user(User) ++ ": Currently <number>d<number>.");
parse_line(Sock, [User, "PRIVMSG", Channel, "&help" | _]) ->
	irc_send(Sock, Channel, parse_user(User) ++ ": Be more specific: '&help roll' or '&help notation'.");

parse_line(Sock, [User, "PRIVMSG", ?nickname, "&roll", N | _]) ->
	irc_send(Sock, parse_user(User), makeroll(N));

parse_line(Sock, [User, "PRIVMSG", Channel, "&roll", N | _]) ->
	irc_send(Sock, Channel, parse_user(User) ++ ": " ++ makeroll(N));

parse_line(Sock, [User, "PRIVMSG", ?nickname, "&100" | _]) ->
	irc_send(Sock, parse_user(User), makeroll("d100"));

parse_line(Sock, [User, "PRIVMSG", Channel, "&100" | _]) ->
	irc_send(Sock, Channel, parse_user(User) ++ ": " ++ makeroll("d100"));

parse_line(Sock, [User, "PRIVMSG", ?nickname, "&vs", N | _]) ->
	irc_send(Sock, parse_user(User), makevs(N));

parse_line(Sock, [User, "PRIVMSG", Channel, "&vs", N | _]) ->
	irc_send(Sock, Channel, parse_user(User) ++ ": " ++ makevs(N));

parse_line(Sock, [User, "PRIVMSG", ?nickname, "&coin" | _]) ->
	irc_send(Sock, parse_user(User), makecoin());

parse_line(Sock, [User, "PRIVMSG", Channel, "&coin" | _]) ->
	irc_send(Sock, Channel, parse_user(User) ++ ": " ++ makecoin());

parse_line(_, _) -> 0.
