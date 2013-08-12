bot.beam: bot.erl botutils.erl botparse.erl botsettings.erl
	erlc bot.erl

.PHONY: start
start: bot.beam
	erl -run bot connect
