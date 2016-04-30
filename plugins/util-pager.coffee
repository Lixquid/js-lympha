lympha.on "ready", ->
	lympha.dbRun( """
		CREATE TABLE IF NOT EXISTS pager(
			owner TEXT,
			phrase TEXT,
			UNIQUE( owner, phrase )
		);
	""" ).then( ->
		lympha.dbRun """
			CREATE TABLE IF NOT EXISTS pager_settings (
				owner TEXT PRIMARY KEY,
				notifytype INTEGER
			);
		"""
	).catch( ( err ) -> console.error err )

lympha.registerPlugin
	group: "pager"
	name: "Pager - Add"
	command: "pgadd"
	syntax: "pgadd <phrase>"
	summary: "Adds a phrase to your personal pager."
	onCommand: ( msg, args ) ->
		arg = args[1]
		return ERROR_USER unless arg?

		arg = arg.toLowerCase()

		@dbRun( "INSERT INTO pager VALUES ( $id, $phrase )",
			$id: msg.sender.id
			$phrase: arg
		).then( =>
			@reply( msg, "Ok, I'll let you know if anyone says `#{arg}`." )
		).catch( ( err ) =>
			if err.message.indexOf( "UNIQUE constraint failed" ) > -1
				@reply( msg, "You're already listening for `#{arg}`!" )
			else
				@logErrorMsg( msg, err )
		)

lympha.registerPlugin
	group: "pager"
	name: "Pager - Remove"
	command: "pgrm"
	syntax: "pgrm <phrase>"
	summary: "Removes a phrase from your personal pager."
	onCommand: ( msg, args ) ->
		arg = args[1]
		return ERROR_USER unless arg?

		arg = arg.toLowerCase()

		@dbGet( "SELECT * FROM pager WHERE owner = $id
			AND phrase = $phrase",
			$id: msg.sender.id,
			$phrase: arg
		).then( ( row ) =>
			if not row
				@reply( msg, "You're not listening for `#{arg}`!" )
				throw null
			@dbRun( "DELETE FROM pager WHERE owner = $id
				AND phrase = $phrase",
				$id: msg.sender.id,
				$phrase: arg
			)
		).then( =>
			@reply( msg, "Ok, I've removed `#{arg}` from your pager." )
		).catch( ( err ) => @logErrorMsg( msg, err ) )

pingTimeout = {}

lympha.registerPlugin
	group: "pager"
	name: "Pager - List"
	command: "pgls"
	syntax: "pgls"
	summary: "Lists all phrases in your personal pager."
	onCommand: ( msg, args ) ->
		@dbAll( "SELECT * FROM pager WHERE owner = $id",
			$id: msg.sender.id
		).then( ( rows ) =>
			if rows.length == 0
				@reply( msg, "You're not listening for any phrases!" )
			else
				@reply( msg, """
					\nYou're listening for:
					#{("`" + row.phrase + "`" for row in rows).join("\n")}
				""" )
		)
	onMessage: ( msg ) ->
		now = (new Date).getTime()
		txt = msg.content.toLowerCase()

		# Deactivate pager for 45 seconds after talking
		pingTimeout[ msg.sender.id.toString() ] = now + 45 * 1000
		@dbEach( """
			SELECT *
			FROM pager
				INNER JOIN pager_settings
				ON
					pager.owner = pager_settings.owner
		""" ).then( ( row ) =>
			if row.owner == msg.sender.id
				return
			if pingTimeout[ row.owner ]? and pingTimeout[ row.owner ] > now
				return
			if txt.indexOf( row.phrase ) > -1
				# only ping every 30 seconds
				pingTimeout[ row.owner ] = now + 30 * 1000

				if row.notifytype == 0 or row.notifytype == 2
					@sendMessage( msg.channel.id, "Pinging <@#{row.owner}>!" )
				if row.notifytype == 1 or row.notifytype == 2
					@sendMessage( row.owner, """
						:exclamation:: #{msg.channel.server.name}, \
						##{msg.channel.name}
						**#{msg.sender}**: #{msg.content}
						https://discordapp.com/channels/#{msg.channel.server.id}/\
						#{msg.channel.id}
					""" )
		).catch( ( err ) -> console.error( err ) )

lympha.registerPlugin
	group: "pager"
	name: "Pager - Type"
	command: "pgtype"
	syntax: "pgtype <chat|dm|both>"
	summary: "Sets how pager should alert you."
	helptext: """
		`pgtype chat`
		Sets pager notifications to appear in the chat mentioned.

		`pgtype dm`
		Sets pager notifications to be direct messaged to you, with a link
		to the chat.

		`pgtype both`
		Sets pager notifications to appear in the chat AND to be direct
		messaged to you.
	"""
	onCommand: ( msg, args ) ->
		arg = args[1]
		if not arg
			return ERROR_USER
		arg = arg.toLowerCase()

		switch arg
			when "chat", "dm", "both"
				setting = 0
				setting = 1 if arg == "dm"
				setting = 2 if arg == "both"
				@dbRun(
					"""
						INSERT OR REPLACE INTO pager_settings VALUES (
							$id, $setting
						)
					""",
					$id: msg.sender.id,
					$setting: setting
				).then( =>
					@reply( msg, "Your pager settings have been saved." )
				).catch( ( err ) -> console.error err)
			else
				@reply( msg, "Unknown alert type! Use either `chat`,
					`dm`, or `both`." )
