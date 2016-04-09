parseTime = ( txt ) ->
	switch
		when match = txt.match /^\d+$/
			return parseInt( match[0] )
		when match = txt.match /^(\d+)m$/i
			return parseInt( match[1] ) * 60
		when match = txt.match /^(\d+)h$/i
			return parseInt( match[2] ) * 3600

timeEnglish = ( num ) ->
	switch
		when num == 1
			return "1 second"
		when num < 60
			return num + " seconds"
		when 60 <= num < 120
			return "1 minute"
		when num < 3600
			return Math.floor( num / 60 ) + " minutes"
		when 3600 <= num < 7200
			return "1 hour"
		else
			return Math.floor( num / 3600 ) + " hours"

timers = []

lympha.registerPlugin
	group: "util"
	name: "Timer"
	command: "timer"
	syntax: "timer <length> [message]"
	summary: "Sets a timer to alert you in the future."
	helptext: """
		`timer <[n]|[n]s|[n]m|[n]h>`
		Alerts you in `n` seconds / minutes / hours.

		`timer <[n]|[n]s|[n]m|[n]h> [message]`
		Alerts you in `n` seconds / minutes / hours with a custom message.
	"""
	onCommand: ( msg, args, txt ) ->
		if not args[1]
			return ERROR_USER
		time = parseTime( args[1] )
		if not time or time < 0
			return @reply( msg, "You must use a valid time!" )
		return
