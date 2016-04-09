lympha.registerPlugin
	group: "random"
	name: "Random Player"
	commands: [ "randply" ]
	syntax: "randply [question]"
	summary: "Ask a question, and lympha will tell you who best fits the
		question."
	onCommand: ( msg ) ->
		users = []
		for user in msg.channel.server.members
			if @shouldIgnore( user, msg.channel.server )
				continue
			if user.status == "offline"
				continue
			users.push user
		@reply( msg, users[ Math.floor( Math.random() * users.length ) ] )
