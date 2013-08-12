-module(bot).
-export([connect/0]).
-compile(export_all).

-include("botsettings.erl").

logger(Log) ->
	receive
		{write, Term} ->
			io:fwrite(Log, "~p: ~p~n", [erlang:localtime(), Term]),
			logger(Log)
	end.

connect() ->
        {ok, Sock} = gen_tcp:connect(?server, ?port, [{packet, line}]),
	{ok, IoDevice} = file:open(?logfile, [append]),
	register(logp, spawn(fun() -> logger(IoDevice) end)),
        gen_tcp:send(Sock, "NICK " ++ ?nickname ++ "\r\n"),
        gen_tcp:send(Sock, "USER " ++ ?nickname ++ " blah blah :I am SamBot! &help me for more information.\r\n"),
%	irc_send(Sock, "nickserv", "identify lblhack"),
	receive after 5000 -> ok end,
        loop(Sock).

loop(Sock) ->
        receive
                {tcp, Sock, Data} ->
			logp ! {write, Data},
                        parse_line(Sock, string:tokens(Data, ": \r\n")),
                        loop(Sock)
        end.

irc_mode(Sock, Channel, Mode, User) ->
        S = "MODE " ++ Channel ++ " " ++ Mode ++ " " ++ User ++ "\r\n",
        gen_tcp:send(Sock, S),
	logp ! {write, S}.

irc_send(Sock, To, Message) ->
	Msgs = chop(Message, 0, [], []),
	send_msgs(Sock, To, Msgs).
send_msgs(_, _, []) -> ok;
send_msgs(Sock, To, [H|T]) ->
        S = "PRIVMSG " ++ To ++ " :" ++ H ++ "\r\n",
        gen_tcp:send(Sock, S),
	logp ! {write, S},
	send_msgs(Sock, To, T).

irc_gen(Sock, Type, To, Message) ->
	S = Type ++ " " ++ To ++ " :" ++ Message ++ "\r\n",
        gen_tcp:send(Sock, S),
	logp ! {write, S}.

chop([], _, A, R) -> R ++ [A];
chop([$ |T], 220, A, R) -> chop(T, 0, [], R ++ [A]);
chop([H|T], 220, A, R) -> chop(T, 220, A ++ [H], R);
chop([H|T], N, A, R) -> chop(T, N+1, A ++ [H], R).

-include("botutils.erl").
-include("botparse.erl").
