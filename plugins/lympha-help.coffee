## Functions ###################################################################

titleCase = ( str ) ->
	return str.charAt(0).toUpperCase() + str.slice(1)

getPluginsSorted = ->
	sortedPlugins = lympha.plugins.slice()
	sortedPlugins.sort( ( a, b ) ->
		if not a.group or not a.name
			console.log a
		if a.group == b.group
			return a.name.localeCompare( b.name )
		else
			return a.group.localeCompare( b.group )
	)
	return sortedPlugins

## Command #####################################################################

lympha.registerPlugin
	group: "lympha"
	name: "Help"
	command: "help"
	syntax: "help [command]"
	summary: "Gets usage information for Lympha."
	helptext: """
		`help`
		Displays status for lympha, as well as summaries for all commands.
		(Note: Commands with restricted access will only be shown in DMs)

		`help command`
		Displays detailed help for a command.
	"""
	onCommand: ( msg, args ) ->
		if not args[1]
			txt = """
				Hello! I'm Lympha, the little bot that could. :heart:
				I was made by Lixquid.

				Invite me to your server!
				https://discordapp.com/oauth2/authorize?&client_id=165060119711711232&scope=bot

				Here are all the neat things I can do!
				(You can run a command with `@Lympha <command>`.)
				(Type `@Lympha help <command>` to get some detailed info \
				about a command.)
				#{if msg.channel.isPrivate then "" else
					"(Restricted commands will only appear if you DM me \
						`help`.)"}


				"""

			group = null
			for plugin in getPluginsSorted()
				if plugin.access
					if not msg.channel.isPrivate or
						plugin.access > @getAccess( msg.sender )
							# 5
							continue

				if plugin.group != group
					group = plugin.group
					txt += "**#{titleCase( plugin.group )}**\n"

				txt += "    `#{lympha.config.commandPrefix or "@Lympha "}"
				txt += "#{plugin.syntax}` - #{plugin.summary}\n"

		else
			search = args[1].toLowerCase()
			target = null
			for plugin in lympha.plugins
				if plugin.access
					if not msg.channel.isPrivate or
						plugin.access > @getAccess( msg.sender )
							continue

				if plugin.name.toLowerCase() == search or
					plugin.command == search or
					search in ( plugin.commands or {} )
						target = plugin
						break

			if not target
				return @reply( msg, "I couldn't find a plugin with that name!" )

			txt = "\n" + @pluginHelpText( target )

		if txt.length < 2000
			@reply( msg, txt )
		else
			chunk = ""
			delay = 100
			for line in txt.split "\n"
				chunk += line + "\n"
				if chunk.length > 1500
					c = chunk
					setTimeout( =>
						if delay == 100
							@reply( msg, c )
						else
							@sendMessage( msg.channel, c )
					, delay )
					delay += 100
					chunk = ""
			if chunk != ""
				setTimeout( =>
					if delay == 100
						@reply( msg, chunk )
					else
						@sendMessage( msg.channel, chunk )
				, delay )

			# cb = ( err ) =>
			# 	setTimeout( =>
			# 		txt = txt.slice( 1499 )
			# 		if err
			# 			return @logErrorMsg( msg, err )
			# 		if txt
			# 			lympha.reply( msg, txt.slice( 0, 1499 ), cb )
			# 	, 100 )
			# @reply( msg, txt.slice( 0, 1499 ), cb )
