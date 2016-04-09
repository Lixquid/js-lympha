safeEval = require "safe-eval"

lympha.registerPlugin
	group: "util"
	name: "Calculate"
	command: "calc"
	syntax: "calc <expression>"
	summary: "Calculates an expression and returns it."
	access: ACCESS_TRUSTED
	onCommand: ( msg, _, txt ) ->
		try
			@reply( msg, safeEval( txt ) )
		catch ex
			id = @logError( ex )
			@reply( msg, "I don't understand that at all! [#{id}]" )
