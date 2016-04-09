coffeeScript = require "coffee-script"

lympha.registerPlugin
	group: "dev"
	name: "Dev Echo"
	command: "dev.echo"
	syntax: "dev.echo <text>"
	summary: "Echoes back whatever was said."
	access: ACCESS_DEV
	onCommand: ( msg, _, txt ) ->
		@reply( msg, txt )

lympha.registerPlugin
	group: "dev"
	name: "Dev Eval"
	command: "dev.eval"
	syntax: "dev.eval <code>"
	summary: "Evaluates the expression given."
	helptext: """
		`dev.eval <code>`
		Evalues the Javascript given.
	"""
	access: ACCESS_DEV
	onCommand: ( msg, _, txt ) ->
		coffee = false
		if match = txt.match( /^```(coffee)?([\s\S]+)```\s*$/ )
			txt = match[2]
			if match[1]
				coffee = true

		if coffee
			result = eval( coffeeScript.compile( txt, bare: true ) )
		else
			result = eval( txt )
		if result?
			@reply( msg, result )
			console.log result

reportError = ( msg, error ) ->
	lympha.sendMessage( msg.channel, """
		**Error Report** (ID: `#{error.id}`)
		Plugin: *#{error.plugin?.name or "None"}*
		Message: `#{error.error.message}`
		Stacktrace:
		```
		#{error.error.stack}
		```
	""" )
lympha.registerPlugin
	group: "dev"
	name: "Dev Error Report"
	command: "dev.errorreport"
	syntax: "dev.errorreport [id]"
	summary: "Reports back stored errors."
	helptext: """
		`dev.errorreport`
		Reports back the last stored errors.

		`dev.errorreport [id]`
		Reports back stored errors.
	"""
	access: ACCESS_DEV
	onCommand: ( msg, args ) ->
		arg = args[1]

		if not arg
			error = lympha.errorCache.pop()
			if error
				reportError( msg, error )
			else
				@reply( msg, "No unseen errors to report!" )
		else if num = parseInt( arg )
			for error in lympha.errorCache by -1
				if error.id != num
					continue
				reportError( msg, error )
			return @reply( msg, "No error with that id!" )

lympha.registerPlugin
	group: "dev"
	name: "Dev Force Except"
	command: "dev.forceexcept"
	syntax: "dev.forceexcept"
	summary: "Forces an exception."
	access: ACCESS_DEV
	onCommand: ( _, args ) ->
		throw new Error( "Forced Exception" )

lympha.registerPlugin
	group: "dev"
	name: "Dev DB Query"
	command: "dev.db"
	syntax: "deb.db <query>"
	summary: "Runs a database query."
	access: ACCESS_DEV
	onCommand: ( msg, _, txt ) ->
		@dbAll( txt ).then( ( rows ) =>
			if rows.length == 0
				return @reply( msg, "Query executed." )
			txt = "Query executed. Results:\n"
			for row in rows
				txt += ( "#{k}: #{v}" for k, v of row ).join( ", " ) + "\n"
			@reply( msg, txt )
		)
