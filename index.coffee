#!/usr/bin/env coffee

## Dependencies ################################################################

discordJS = require "discord.js"
fs = require "fs"
http = require "http"
sqlite3 = require( "sqlite3" ).verbose()

global.lympha = new discordJS.Client()

## Config ######################################################################

try
	lympha.config = require "#{__dirname}/config.json"
catch ex
	console.error "Error when attempting to load config.json:"
	console.error ex.message
	console.error ex.stack
	process.exit 1

global.ACCESS_ALL = 0
global.ACCESS_TRUSTED = 10
global.ACCESS_MOD = 50
global.ACCESS_ADMIN = 80
global.ACCESS_DEV = 99

global.ERROR_USER = 1

## Functions ###################################################################

typinglocks = {}
lympha.startTypingLock = ( channel, id ) ->
	typinglocks[ channel ] ?= {}
	typinglocks[ channel ][ id ] = true
	lympha.startTyping( channel )
	setTimeout( ( -> lympha.stopTypingLock( channel, id ) ), 15e3 )
lympha.stopTypingLock = ( channel, id ) ->
	typinglocks[ channel ] ?= {}
	delete typinglocks[ channel ][ id ]
	for _ of typinglocks[ channel ]
		return
	lympha.stopTyping( channel )

lympha.delayedReply = ( msg, reply ) ->
	lympha.startTypingLock( msg.channel, msg )
	setTimeout( ( ->
		lympha.reply( msg, reply )
		lympha.stopTypingLock( msg.channel, msg )
	), reply.length * 5 + 100 )

lympha.getAccess = ( user ) ->
	if user.id
		user = user.id
	return lympha.config.access[ user.toString() ] or 0

lympha.httpGet = ( url ) ->
	return new Promise( ( accept, reject ) ->
		http.get( url, ( res ) ->
			body = ""
			res.on "data", ( d ) ->
				body += d
			res.on "end", ->
				accept( body )
		).on( "error", reject )
	)

lympha.shouldIgnore = ( ply_or_msg, server ) ->
	if ply_or_msg.sender
		ply = ply_or_msg.sender
		msg = ply_or_msg
		server = msg.channel.server
	else
		ply = ply_or_msg

	if lympha.config.ignore
		for id in lympha.config.ignore
			if id == ply.id
				return true

	if server and lympha.config.ignoreRules
		ignoreRules = lympha.config.ignoreRules[ server.id ]

		if ignoreRules?.roles
			for role in server.rolesOf( ply )
				if role.name in ignoreRules.roles
					return true
		if ignoreRules?.channels and msg
			for channel in ignoreRules.channels
				if channel == msg.channel.name
					return true


errorCurrentPlugin = null
lympha.errorCache = []
lympha.logError = ( error ) ->
	console.error error.message
	console.error error.stack

	id = Math.floor( Math.random() * 1e8 )

	lympha.errorCache.push
		id: id
		error: error
		plugin: errorCurrentPlugin

	return id

lympha.logErrorMsg = ( msg, error ) ->
	id = lympha.logError( error )
	lympha.reply( msg, "Sorry, I broke! <@#{lympha.config.errorMaster}>, help!
		[#{id}]" )

lympha.findMentionedPlayer = ( msg, filters, filter_fn ) ->
	if not filter_fn? and typeof filters == "function"
		filter_fn = filters
		filters = {}

	for user in msg.mentions
		if user == lympha.user and not filters.allow_lympha
			continue
		if user == msg.sender and not filters.allow_sender
			continue
		if filter_fn?
			continue if not filter_fn( user )

		return user

lympha.findMentionedPlayers = ( msg, filters, filter_fn ) ->
	if not filter_fn?
		filter_fn = filters
		filters = {}

	for user in msg.mentions
		if user == lympha.user and not filters.allow_lympha
			continue
		if user == msg.sender and not filters.allow_sender
			continue
		if filter_fn?
			continue if not filter_fn( user )

		user

lympha.openDatabase = ->
	return new Promise( ( accept, reject ) ->
		lympha.db = new sqlite3.Database( "db.db", ( err ) ->
			if not err
				accept()
			else
				reject( err )
		)
	)

dbProto = ( action, sql, args ) ->
	if args.length == 1 and args[0]? and typeof args[0] == "object"
		args = args[0]

	return new Promise( ( accept, reject ) ->
		callback = ( err, row ) ->
			if err
				reject( err )
			else
				accept( row )
		lympha.db[ action ]( sql, args, callback )
	)

lympha.dbRun = ( sql, args... ) -> dbProto( "run", sql, args )
lympha.dbGet = ( sql, args... ) -> dbProto( "get", sql, args )
lympha.dbAll = ( sql, args... ) -> dbProto( "all", sql, args )
lympha.dbEach = ( sql, args... ) -> dbProto( "each", sql, args )

## Plugins #####################################################################

lympha.plugins = []

lympha.pluginHelpText = ( plugin ) ->
	txt = "**#{plugin.name}** "
	if plugin.commands
		txt += "(`" +
			( c for c in plugin.commands ).join( "`, `" ) +
			"`)\n"
	else
		txt += "(`" + plugin.command + "`)\n"
	txt += plugin.summary
	if plugin.helptext
		txt += "\n\n" + plugin.helptext
	else
		txt += "\n`" + ( lympha.config.commandPrefix or "@Lympha " ) +
			plugin.syntax + "`"
	return txt

lympha.registerPlugin = ( plugin ) ->
	lympha.plugins.push( plugin )

lympha.reloadPlugins = ->
	lympha.plugins.length = 0
	for file in fs.readdirSync( "#{__dirname}/plugins" )
		require( "#{__dirname}/plugins/#{file}" )
	if lympha.config.disabledPlugins
		for plugin in lympha.plugins
			com = plugin.command ? plugin.commands[0]
			if com in lympha.config.disabledPlugins
				plugin.disabled = true

lympha.reloadPlugins()

## Bot #########################################################################

lympha.on "error", ( err ) ->
	console.error "ERROR: #{err.message} #{err.stack}"

lympha.on "message", ( msg ) ->

	## Logging ##

	if msg.channel.isPrivate
		console.log "[PRIVATE] #{msg.sender.username}: #{msg.cleanContent}"
	else
		console.log "[##{msg.channel.name}] @#{msg.sender.username}:
			#{msg.cleanContent}"

	# Ignore everything emitted by lympha

	if msg.sender == lympha.user
		return

	# Check ignore rules, see if should ignore

	if @shouldIgnore( msg )
		return

	# Send message event to all plugins

	for plugin in @plugins
		if plugin.disabled
			continue

		try
			errorCurrentPlugin = plugin
			plugin.onMessage?.call( this, msg )
		catch ex
			@logErrorMsg( msg, ex )

	# Ignore / Mutate arguments
	txt = msg.content
	loop
		# DM, respond as is
		if msg.channel.isPrivate
			break
		# @Mentioned, strip mention
		if txt.indexOf( "<@#{@user.id}>" ) == 0
			txt = txt.replace( /^<@\d+>\s+/, "" )
			break
		# Command prefix
		if @config.commandPrefix and txt.indexOf( @config.commandPrefix ) == 0
			txt = txt.substr( @config.commandPrefix.length ).trimLeft()
			break

		# Not referenced, ignore
		return

	args = txt.split( /\s+/ )
	if args.length == 0
		return
	txt = txt.replace( /^\S+\s+/, "" )

	command = args[0].toLowerCase()

	for plugin in @plugins
		if plugin.disabled
			continue
		if command not in ( plugin.commands ? [] ) and plugin.command != command
			continue
		if plugin.access and @getAccess( msg.sender ) < plugin.access
			continue

		try
			errorCurrentPlugin = plugin
			ret = plugin.onCommand?.call( this, msg, args, txt )
			switch ret
				when ERROR_USER
					@reply( msg, "\n" + @pluginHelpText( plugin ) )

		catch ex
			@logErrorMsg( msg, ex )

	errorCurrentPlugin = null

lympha.on "ready", ->
	console.log "Lympha is ready to play!"
	@setPlayingGame "@Lympha help"

lympha.openDatabase().then( ->
	if lympha.config.token
		lympha.loginWithToken(
			lympha.config.token,
			lympha.config.email,
			lympha.config.password
		)
	else
		lympha.login( lympha.config.email, lympha.config.password )

	try require "#{__dirname}/test.coffee"
)
