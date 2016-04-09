lympha.registerPlugin
	group: "util"
	name: "Ping"
	command: "ping"
	syntax: "ping"
	summary: "Get a Pong!"
	onCommand: ( msg ) ->
		@reply( msg, "Pong!" )
