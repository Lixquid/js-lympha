lympha.registerPlugin
	group: "util"
	name: "When They're Back"
	commands: [ "whentheyreback", "wtb" ]
	syntax: "whentheyreback <@player>"
	summary: "Lets you know when someone is online."
	onCommand: ( msg ) ->
		target = @findMentionedPlayer( msg )
		if not target
			return @reply( msg, "Couldn't find mentioned player!" )
		if target.status == "online"
			return @reply( msg, "That player is already here!" )

		@reply( msg, "Ok, I'll let you know when they get back." )

		letmeknow = =>
			if target.status == "online"
				@reply( msg, "#{target} is online!" )
			else
				setTimeout( letmeknow, 1000 )
		letmeknow()
