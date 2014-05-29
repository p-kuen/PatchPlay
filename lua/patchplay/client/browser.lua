cl_PPlay.APIKeys = {
	
	dirble = "4fb8ff3c26a13ccbd6fd895ccbf5645845911ce9"
}

cl_PPlay.browser = {}

cl_PPlay.browser.currentBrowse = {

	url = "",
	stage = 0,
	args = {}

}

cl_PPlay.browser.history = {}

cl_PPlay.BrowseURL = {

	dirble = { 

	"primaryCategories/apikey/" .. cl_PPlay.APIKeys.dirble,
	"childCategories/apikey/" .. cl_PPlay.APIKeys.dirble .. "/primaryid/[id]",
	"stations/apikey/" .. cl_PPlay.APIKeys.dirble .. "/id/[id]"

	}

}

function cl_PPlay.resetBrowse()

	cl_PPlay.browser.currentBrowse = {

		url = "",
		stage = 0,
		args = {}

	}

	cl_PPlay.browser.history = {}

end

function cl_PPlay.browse( list )

	if table.Count(cl_PPlay.browser.currentBrowse.args) == 0 and cl_PPlay.browser.currentBrowse.stage != 0 then return end

	if cl_PPlay.browser.currentBrowse.stage == 3 then

		if list.mode == "server" then
			cl_PPlay.sendToServer( cl_PPlay.browser.currentBrowse.args.streamurl, cl_PPlay.browser.currentBrowse.args.name, "play" )
		else
			cl_PPlay.play( cl_PPlay.browser.currentBrowse.args.streamurl, cl_PPlay.browser.currentBrowse.args.name, "private" )
		end
		return

	end

	cl_PPlay.browser.currentBrowse.url = ""

	cl_PPlay.browser.currentBrowse.stage = cl_PPlay.browser.currentBrowse.stage + 1

	local rawURL = cl_PPlay.BrowseURL.dirble[cl_PPlay.browser.currentBrowse.stage]
	local newURL = string.gsub( rawURL, "%[(%w+)%]", cl_PPlay.browser.currentBrowse.args )

	cl_PPlay.browser.currentBrowse.url = "http://api.dirble.com/v1/" .. newURL .. "/format/json"

	table.insert( cl_PPlay.browser.history, cl_PPlay.browser.currentBrowse.url )

	cl_PPlay.getJSONInfo( cl_PPlay.browser.currentBrowse.url, function(entry)

		list:Clear()

		table.foreach(entry, function( key, value )

			if cl_PPlay.browser.currentBrowse.stage == 3 and !cl_PPlay.checkValidURL( value.streamurl ) or value.status == 0 then return end
			

			local line = list:AddLine( value.name )
			if cl_PPlay.browser.currentBrowse.stage == 3 then
				line.url = value.streamurl
				line.name = value.name
			end
			line.id = value.id

		end)

		cl_PPlay.browser.currentBrowse.args = {}


	end)



end

function cl_PPlay.browseback( list )

	if #cl_PPlay.browser.history == 0 then return end
	PrintTable(cl_PPlay.browser.history)

	cl_PPlay.browser.currentBrowse.url = cl_PPlay.browser.history[#cl_PPlay.browser.history - 1]

	cl_PPlay.getJSONInfo( cl_PPlay.browser.currentBrowse.url, function(entry)

		list:Clear()

		table.foreach(entry, function( key, value )

			local line = list:AddLine( value.name )
			line.id = value.id

		end)

	end)

	table.remove( cl_PPlay.browser.history, #cl_PPlay.browser.history )
	cl_PPlay.browser.currentBrowse.stage = cl_PPlay.browser.currentBrowse.stage - 1

end

function cl_PPlay.addtoplaylist( list )

	if cl_PPlay.browser.currentBrowse.stage != 3 or table.Count(cl_PPlay.browser.currentBrowse.args) == 0 then return end

	if list.mode == "server" then

		cl_PPlay.saveNewServerStream(cl_PPlay.browser.currentBrowse.args.streamurl, cl_PPlay.browser.currentBrowse.args.name, "station")

	else

		cl_PPlay.saveNewStream( { name = cl_PPlay.browser.currentBrowse.args.name,  url = cl_PPlay.browser.currentBrowse.args.streamurl, mode = "station" } )
		cl_PPlay.getStreamList()

	end

end