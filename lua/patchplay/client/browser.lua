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

function cl_PPlay.browse( list, backURL )

	if table.Count(cl_PPlay.browser.currentBrowse.args) == 0 and cl_PPlay.browser.currentBrowse.stage != 0 then return end

	if cl_PPlay.browser.currentBrowse.stage == 3 and backURL == nil then

		if list.mode == "server" then
			cl_PPlay.sendToServer( cl_PPlay.browser.currentBrowse.args.streamurl, cl_PPlay.browser.currentBrowse.args.name, "play" )
		else
			cl_PPlay.play( cl_PPlay.browser.currentBrowse.args.streamurl, cl_PPlay.browser.currentBrowse.args.name, "private" )
		end
		return

	end

	cl_PPlay.browser.currentBrowse.url = ""

	if backURL == nil then

		local rawURL = cl_PPlay.BrowseURL.dirble[cl_PPlay.browser.currentBrowse.stage + 1]
		local newURL = string.gsub( rawURL, "%[(%w+)%]", cl_PPlay.browser.currentBrowse.args )

		cl_PPlay.browser.currentBrowse.url = "http://api.dirble.com/v1/" .. newURL .. "/format/json"

	else

		cl_PPlay.browser.currentBrowse.url = "http://api.dirble.com/v1/" .. backURL .. "/format/json"

	end

	cl_PPlay.getJSONInfo( cl_PPlay.browser.currentBrowse.url, function(entry)

		list:Clear()

		table.foreach(entry, function( key, value )

			if cl_PPlay.browser.currentBrowse.stage == 2 and !cl_PPlay.checkValidURL( value.streamurl ) or value.status == 0 then return end
			

			local line = list:AddLine( value.name )
			if cl_PPlay.browser.currentBrowse.stage == 2 then
				line.url = value.streamurl
				line.name = value.name
			end
			line.id = value.id

		end)

		if backURL == nil then

			cl_PPlay.browser.currentBrowse.stage = cl_PPlay.browser.currentBrowse.stage + 1
			table.insert( cl_PPlay.browser.history, cl_PPlay.browser.currentBrowse )

		else

			cl_PPlay.browser.currentBrowse.stage = cl_PPlay.browser.currentBrowse.stage - 1

		end

		cl_PPlay.browser.currentBrowse.args = {}


	end)



end
--concommand.Add( "pplay_browse", cl_PPlay.browser)

function cl_PPlay.browseback( list )

	if #cl_PPlay.browser.history == 0 then return end

	local rawURL = cl_PPlay.BrowseURL.dirble[cl_PPlay.browser.currentBrowse.stage - 1]
	local newURL = string.gsub( rawURL, "%[(%w+)%]", cl_PPlay.browser.history[#cl_PPlay.browser.history].args )

	cl_PPlay.browse( list, newURL )

	table.remove( cl_PPlay.browser.history, #cl_PPlay.browser.history )

end