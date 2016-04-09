images = {
	lewd: [
		"http://i.imgur.com/rS4vjLu.gif"
		"http://i.imgur.com/MbDBSNf.gif"
		"http://i.imgur.com/MzkWXI1.gif"
		"http://i.imgur.com/mQHK2zo.gif"
		"http://i.imgur.com/SkKuPp5.gif"
		"http://i.imgur.com/qknrvCO.gif"
		"http://i.imgur.com/qd1izBY.gif"
		"http://i.imgur.com/pjQLFi8.png"
	]
	rekt: [
		"http://i.imgur.com/BBkRLfQ.gif"
	]
	doot: [
		"http://i.imgur.com/249KYru.gif"
		"http://i.imgur.com/hWQMTXt.gif"
	]
	woomy: [
		"http://i.imgur.com/MXrUYFV.png"
		"http://i.imgur.com/Ic0BiHS.png"
		"http://i.imgur.com/ptk1Tts.png"
		"http://i.imgur.com/WeiGt9O.png"
		"http://i.imgur.com/fU6f0BQ.jpg"
		"http://i.imgur.com/16pavUI.png"
		"http://i.imgur.com/GtbQNr1.png"
		"http://i.imgur.com/ng6CAJ3.png"
		"http://i.imgur.com/LvOuIAb.png"
		"http://i.imgur.com/jnuNanG.png"
	]
	unsee: [
		"http://i.imgur.com/nDfyJ2L.gif"
	]
	wtf: [
		"http://i.imgur.com/rHC0Oc6.png"
		"http://i.imgur.com/O8Xw5pO.png"
		"http://i.imgur.com/v71GPiq.png"
		"http://i.imgur.com/3Y9lnFQ.png"
	]
	mlady: [
		"http://i.imgur.com/pH5olqQ.jpg"
		"http://i.imgur.com/gaaEWQ9.png"
		"http://i.imgur.com/cFV5GyB.gif"
	]
}

lympha.registerPlugin
	group: "fun"
	name: "Reaction Image"
	command: "show"
	syntax: "show <type> [id]"
	summary: "Shows a random reaction image."
	helptext: """
		`show <type>`
		Shows a random reaction image of `type`.

		`show <type> [num]`
		Shows a specific reaction image of `type`.

		Available types:
		`#{(type + '` (' + a.length + ')' for type, a of images).join( "\n`" )}
	"""
	onCommand: ( msg, args ) ->
		if not args[1]
			return ERROR_USER
		args[1] = args[1].toLowerCase()
		if not images[ args[1] ]
			return ERROR_USER

		if args[2] and num = parseInt( args[2] )
			if num > images[ args[1] ].length
				num = images[ args[1] ].length
		else
			num = Math.floor( Math.random() * images[ args[1] ].length + 1 )

		lympha.sendMessage( msg.channel, images[ args[1] ][ num - 1 ] )
		lympha.deleteMessage( msg )
