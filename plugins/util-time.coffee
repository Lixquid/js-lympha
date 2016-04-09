# TODO: Redo

lympha.registerPlugin
	group: "util"
	name: "Time"
	command: "time"
	syntax: "time [offset]"
	summary: "Reports the current time."
	helptext: """
		`time`
		Reports the current time.

		`time [offset]`
		Reports the current time in the specified timezone.
	"""
	onCommand: ( msg, args ) ->
		offset = 0
		if args[1]
			if match = args[1].match /^(?:GMT)?([+-]?\d+)$/
				offset = parseInt( match[1] )
				offset = Math.min( Math.max( offset, -12 ), 12 )
			# TODO: Country parsing

		now = new Date
		now.setTime( now.getTime() + 1000 * 60 * 60 * offset )

		dateString = now.toISOString().replace( "T", " " ).replace( /\..+/, "" )

		offsetString = null
		if offset == 0
			offsetString = "(GMT)"
		else if offset > 0
			offsetString = "(GMT +#{offset})"
		else
			offsetString = "(GMT #{offset})"

		@reply( msg, dateString + " " + offsetString )
