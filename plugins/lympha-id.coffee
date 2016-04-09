lympha.registerPlugin
	group: "lympha"
	name: "User ID"
	command: "id"
	syntax: "id [@player]"
	summary: "Reports the current user's id."
	helptext: """
		`id`
		Reports the current user's ID.

		`id [@player]`
		Reports the mentioned player's ID.
	"""
	onCommand: ( msg, args ) ->
		if ply = @findMentionedPlayer( msg )
			@reply( msg, "#{ply}'s ID is `#{ply.id}`." )
		else
			@reply( msg, "Your ID is `#{msg.sender.id}`." )

prettyPrintUser = ( user ) ->
	return "*#{user.name}*"

lympha.registerPlugin
	group: "lympha"
	name: "Server IDs"
	command: "lympha.ids"
	syntax: "lympha.ids"
	summary: "Get all IDs for all entities on the server."
	access: ACCESS_MOD
	onCommand: ( msg ) ->
		@reply msg, """

			**#{msg.channel.server.name}** (`#{msg.channel.server.id}`)

			Voice Channels:
			#{
				(
					for channel in msg.channel.server.channels
						if channel.type != "voice"
							continue
						"*#" + channel.name + "* (`" + channel.id + "`)"
				).join( "\n" )
			}

			Text Channels:
			#{
				(
					for channel in msg.channel.server.channels
						if channel.type != "text"
							continue
						"*#" + channel.name + "* (`" + channel.id + "`)"
				).join( "\n" )
			}

			Users:
			#{
				(
					for user in msg.channel.server.members
						"*" + user.name + "* (`" + user.id + "`)"
				).join( "\n" )
			}
		"""
