fs = require "fs"

lympha.registerPlugin
	group: "lympha"
	name: "Reload Plugins"
	command: "lympha.reload"
	syntax: "lympha.reload"
	summary: "Reloads all of Lympha's plugins."
	access: ACCESS_ADMIN
	onCommand: ( msg ) ->
		@reply( msg, "Ok, reloading all plugins.." )
		@reloadPlugins()

lympha.registerPlugin
	group: "lympha"
	name: "Disable Plugin"
	command: "lympha.disable"
	syntax: "lympha.disable <command>"
	summary: "Disables a plugin."
	access: ACCESS_ADMIN
	onCommand: ( msg, args ) ->
		txt = args[1]
		target = null
		for plugin in lympha.plugins
			if plugin.access and plugin.access > @getAccess( msg.sender )
				continue

			if plugin.command == txt or txt in ( plugin.commands or {} )
				target = plugin
				break

		if not target
			return @reply( msg, "No plugin found with that command!" )

		if target.group == "lympha"
			return @reply( msg, "You cannot disable that command!" )

		if target.disabled
			return @reply( msg, "Plugin already disabled!" )
		else
			target.disabled = true
			@config.disabledPlugins.push( target.command ? target.commands[0] )
			return @reply( msg, "#{target.name} has been disabled!" )
lympha.registerPlugin
	group: "lympha"
	name: "Enable Plugin"
	command: "lympha.enable"
	syntax: "lympha.enable <command>"
	summary: "Enables a plugin."
	access: ACCESS_ADMIN
	onCommand: ( msg, args ) ->
		txt = args[1]
		target = null
		for plugin in lympha.plugins
			if plugin.access and plugin.access > @getAccess( msg.sender )
				continue

			if plugin.command == txt or txt in ( plugin.commands or {} )
				target = plugin
				break

		if not target
			return @reply( msg, "No plugin found with that command!" )

		if not target.disabled
			return @reply( msg, "Plugin already enabled!" )
		else
			@config.disabledPlugins.splice(
				@config.disabledPlugins.indexOf(
					target.command ? target.commands[0]
				), 1
			)
			target.disabled = true
			return @reply( msg, "#{target.name} has been enabled!" )

lympha.registerPlugin
	group: "lympha"
	name: "Save Config"
	command: "lympha.saveconfig"
	syntax: "lympha.saveconfig"
	summary: "Saves the current configuration to disk."
	access: ACCESS_ADMIN
	onCommand: ( msg ) ->
		fs.writeFile( "./config.json",
			JSON.stringify( lympha.config, null, '\t' ),
			( err ) =>
				if err
					@reply( msg, "There was a problem writing the config!" )
					console.error err
				else
					@reply( msg, "Configuration saved!" )
		)

lympha.registerPlugin
	group: "lympha"
	name: "Join Server"
	command: "lympha.joinserver"
	syntax: "lympha.joinserver <url>"
	summary: "Joins a server from an invite URL."
	access: ACCESS_ADMIN
	onCommand: ( msg, _, txt ) ->
		@joinServer( txt )

lympha.registerPlugin
	group: "lympha"
	name: "List Servers"
	command: "lympha.listservers"
	syntax: "lympha.listservers"
	summary: "Lists all servers Lympha is connected to."
	access: ACCESS_ADMIN
	onCommand: ( msg ) ->
		@reply( msg, """
			I'm connected to:
			**#{(server.name for server in @servers).join( '**\n**' )}**
		""" )
