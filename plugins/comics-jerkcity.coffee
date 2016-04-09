lympha.registerPlugin
	group: "fun"
	name: "Jerkcity"
	command: "jerkcity"
	syntax: "jerkcity [id]"
	summary: "Gets a jerkcity comic."
	helptext: """
		`jerkcity`
		Gets a random jerkcity comic.

		`jerkcity [id]`
		Gets a jerkcity comic.
	"""
	onCommand: ( msg, args ) ->
		@startTypingLock( msg.channel, msg )
		arg = parseInt( args[1] )

		if not arg
			# Get most recent comic, get it's ID, generate a random number,
			# then get that comic.
			p = @httpGet( "http://www.jerkcity.com/index.json" ).then(
				( json ) =>
					json = JSON.parse( json )
					ep = Math.floor( Math.random() * json.episode + 1 )
					return @httpGet( "http://www.jerkcity.com/json/#{ep}.json" )
			)
		else
			p = @httpGet( "http://www.jerkcity.com/json/#{arg}.json" )

		p.then( ( json ) =>
			console.log "NEXT"
			json = JSON.parse( json )
			@reply( msg, """
				**#{json.episode}**: *#{json.title}*
				#{json.baseurl}#{json.image}
			""" )
		).catch( ( ex ) =>
			@stopTypingLock( msg.channel, msg )
			id = @logError( ex )
			@reply( msg, "Couldn't get the comic :( [#{id}]" )
		)
