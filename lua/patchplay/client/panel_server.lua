










function cl_PPlay.openStreamList( ply, cmd, args )

	local selectedStream = {
		name = "",
		url = ""
	}

	local w, h = 400, 320

	-- FRAME
	local frm = cl_PPlay.addfrm(w, h, "PatchPlay - Server Stream Player", true)

	-- LIST VIEW LABEL
	cl_PPlay.addlbl( frm, "Choose a Stream:", "frame", 15, 30 )

	-- STREAM LIST
	local slv = cl_PPlay.addlv( frm, 15, 50, w - 30, h - 100, {"Name", "Stream"} )

	function fillStreamList()
		slv:Clear()
		table.foreach( cl_PPlay.streamList, function( key, value )

			slv:AddLine( value["name"], value["stream"] )

		end)
	end

	fillStreamList()

	function slv:OnClickLine( line, selected )
		selectedStream["name"] = line:GetValue(1)
		selectedStream["url"] = line:GetValue(2)
		slv:ClearSelection()
		line:SetSelected( true )
	end

	-- DELETE BUTTON IN FRAME
	local dbtn = cl_PPlay.addbtn( frm, "Delete", nil, "frame", {15, h - 40, 80, 25} )

	-- DELETE BUTTON FUNCTION
	function dbtn:OnMousePressed()

		if selectedStream["url"] != "" then
			net.Start( "pplay_deletestream" )
				net.WriteString( selectedStream["url"] )
			net.SendToServer()

			timer.Simple(0.1, fillStreamList)
		end
		
	end

	-- PLAY BUTTON IN FRAME
	local pbtn = cl_PPlay.addbtn( frm, "Stream", nil, "frame", {w - 115, h - 40, 100, 25} )

	-- PLAY BUTTON FUNCTION
	function pbtn:OnMousePressed()
		if selectedStream["url"] != "" then
			cl_PPlay.sendToServer( selectedStream["url"], selectedStream["name"], "play" )
			frm:Close()
			cl_PPlay.UpdateMenus()
		end
	end

end
concommand.Add( "pplay_openStreamList", cl_PPlay.openStreamList )


--CUSTOM FRAME


function cl_PPlay.openCustom( ply, cmd, args )
	
	local w, h = 400, 200

	-- FRAME
	local frm = cl_PPlay.addfrm(w, h, "PatchPlay - Server URL Player", true)

	-- LABEL IN FRAME
	cl_PPlay.addlbl( frm, "Stream URL:", "frame", 15, 30 )

	-- TEXTENTRY IN FRAME
	local te_url = cl_PPlay.addtext( frm, "frame", { 15, 50 }, { w - 30, 22 } )

	-- PLAY BUTTON IN FRAME
	local pbtn = cl_PPlay.addbtn( frm, "Stream", nil, "frame", {w - 115, 82, 100, 20} )

	-- PLAY BUTTON FUNCTION
	function pbtn:OnMousePressed()

		if te_url:GetValue() != "" then
			if te_name != nil and te_name:GetValue() != "" then
				cl_PPlay.sendToServer( te_url:GetValue(), te_Name:GetValue(), "play" )
			else
				cl_PPlay.sendToServer( te_url:GetValue(), "", "play" )
			end
		end

	end

	-- STREAM LABEL
	cl_PPlay.addlbl( frm, "If you want to save the stream to the streamlist, choose a name:", "frame", 15, 112 )

	-- TEXTENTRY IN FRAME
	local te_name = cl_PPlay.addtext( frm, "frame", { 15, 132 }, { w - 30, 22 } )

	-- SAVE BUTTON IN FRAME
	local sabtn = cl_PPlay.addbtn( frm, "Save", nil, "frame", {w - 115, h - 37, 100, 20} )

	-- SAVE BUTTON FUNCTION
	function sabtn:OnMousePressed()

		if te_name:GetValue() != "" and  te_url:GetValue() != "" then

			cl_PPlay.saveNewServerStream(te_url:GetValue(), te_name:GetValue())

			frm:Close()
			cl_PPlay.UpdateMenus()

		elseif te_url:GetValue() == "" then
			print("Not saved! URL is empty!")
		elseif te_name:GetValue() == "" then
			print("Not saved! Name is empty!")
		end
		
	end

	
end
concommand.Add( "pplay_openCustom", cl_PPlay.openCustom )

--SOUNDCLOUD FRAME
function cl_PPlay.openSoundCloud( ply, cmd, args )

	local w, h = 400, 130

	-- FRAME
	local frm = cl_PPlay.addfrm(w, h, "PatchPlay - Server SoundCloud Player", true)

	-- LABEL IN FRAME
	cl_PPlay.addlbl( frm, "SoundCloud URL:", "frame", 15, 30 )

	-- TEXTENTRY IN FRAME
	local te_url = cl_PPlay.addtext( frm, "frame", { 15, 50 }, { w - 30, 22 } )

	-- STREAM LABEL
	cl_PPlay.addlbl( frm, "PatchPlay detects the title of the inserted stream!", "frame", 15, 75 )

	-- PLAY BUTTON IN FRAME
	local pbtn = cl_PPlay.addbtn( frm, "Stream", nil, "frame", {w - 115, 95, 100, 20} )

	-- PLAY BUTTON FUNCTION
	function pbtn:OnMousePressed()

		cl_PPlay.getSoundCloudInfo( te_url:GetValue(), function(entry) 
			cl_PPlay.playStream( entry.stream_url, entry.title, true )
		end)
		
	end

	-- SAVE BUTTON IN FRAME
	local sabtn = cl_PPlay.addbtn( frm, "Save", nil, "frame", {w - 220, 95, 100, 20} )

	-- SAVE BUTTON FUNCTION
	function sabtn:OnMousePressed()

		cl_PPlay.getSoundCloudInfo( te_url:GetValue(), function(entry) 

			cl_PPlay.saveNewServerStream( entry.stream_url, entry.title )

			frm:Close()
			cl_PPlay.UpdateMenus()

		end)
		
	end
	
end
concommand.Add( "pplay_openSoundCloud", cl_PPlay.openSoundCloud )

function cl_PPlay.saveNewServerStream(stream, text)
	local newStream = {
		name = text,
		url = stream
	}

	net.Start( "pplay_savestream" )
		net.WriteTable( newStream )
	net.SendToServer()
end