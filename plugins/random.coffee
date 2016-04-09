eightBallResponses = [
	"It is certain"
	"It is decidedly so"
	"Without a doubt"
	"Yes definitely"
	"You may rely on it"
	"As I see it yes"
	"Most likely"
	"Outlook good"
	"Yes"
	"Signs point to yes"
	"Reply hazy try again"
	"Ask again later"
	"Better not tell you now"
	"Cannot predict now"
	"Concentrate and ask again"
	"Don't count on it"
	"My reply is no"
	"My sources say no"
	"Outlook not so good"
	"Very doubtful"
]
lympha.registerPlugin
	group: "random"
	name: "8 Ball"
	commands: [ "8ball", "8" ]
	syntax: "8ball [question]"
	summary: "Peer into the mysterious 8ball, and get an equally mysterious
		response."
	onCommand: ( msg ) ->
		@reply( msg, eightBallResponses[ Math.floor( Math.random() * 20 ) ] )

lympha.registerPlugin
	group: "random"
	name: "Flip Coin"
	command: "flipcoin"
	syntax: "flipcoin [question]"
	summary: "Flips a coin."
	onCommand: ( msg ) ->
		@reply( msg, if Math.random() > 0.5 then "Heads!" else "Tails!" )

lympha.registerPlugin
	group: "random"
	name: "Roll Dice"
	command: "roll"
	syntax: "roll [n]d[m]"
	summary: "Rolls a die / dice."
	helptext: """
		`roll`
		Rolls a d6.

		`roll d[m]`
		Rolls a die with the maximum `m`.

		`roll [n]d[m]`
		Rolls `n` dice with the maximum `m`.
	"""
	onCommand: ( msg, _, args ) ->
		if match = args.match( /(\d+)d(\d+)/ )
			num = parseInt( match[1] ) ? 1
			max = parseInt( match[2] )

			dice = []
			for [1..num]
				dice.push( Math.floor( Math.random() * max + 1 ) )

			@reply( msg, """


				You rolled:
				#{dice.join( ", " )}
				= #{dice.reduce( ( a, b ) -> a + b )}
			""" )
		else if match = args.match( /d(\d+)/ )
			max = parseInt( match[1] )

			@reply( msg, "You rolled: " +
				Math.floor( Math.random() * max + 1 ) )
		else
			@reply( msg, "You rolled: " +
				Math.floor( Math.random() * 6 + 1 ) )
