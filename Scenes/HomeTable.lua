--[[
%% autostart
%% properties
%% events
%% globals
--]]

local debug = true --set to false to stop debug messages

-- HOME TABLE FOR ANYTHING IN ADDITION TO DEVICES, VDs, iOS DEVICES
-- EDIT TO YOUR NEEDS OR KEEP BLANK: jsonHome = {}
jsonHome = {

	scene = {
		MainScene=614,AlarmControl=598,rebootHC2=593,goodMorning=463,goodNight=331,LeavingHome=483,welcomeHome=488,quietMorning=499,kidsToBed=490,plaroomTvOn=580,firstFloorMusicOn=579,firstFloorAllOff=578,
		hallSceneControl=519,StairsLight30=556,GateOpen5=526,GateOpenHold=361,GateOpenClose=425,DumpEventLog=565,PlayroomOff=617
	},

	users = {
		admin=2,frank=1564,sylvia=1565
	},
}

-- NO USER EDITS NEEDED BELOW

local function log(str) if debug then fibaro:debug(str); end; end 

devices=fibaro:getDevicesId({visible = true, enabled = true}) -- get list of all visible and enabled devices
log("Fill hometable with "..#devices.." devices")

-- FILL THE HOMETABLE WITH ALL VDs, DEVICES AND iOS DEVICES
for k,i in ipairs(devices) do
	deviceName=string.gsub(fibaro:getName(i), "%s+", "") -- eliminate spaces in devicename

	-- Uncomment this to eliminate all non-alphanumeric characters in devicename
	-- deviceName=string.gsub(fibaro:getName(i), "%W", "") 
	
	if fibaro:getType(i) == "virtual_device" then -- Add VDs to Hometable
		if jsonHome.VD == nil then -- Add VD to the table
			jsonHome.VD = {}  
		end
		jsonHome.VD[deviceName]=i
		log("i="..i..", type="..fibaro:getType(i)..", device="..deviceName)
	elseif fibaro:getType(i) == "iOS_device" then -- Add iOS devices to Hometable
		if jsonHome.iOS == nil then -- Add iOS devices to the table
			jsonHome.iOS = {}  
		end
		jsonHome.iOS[deviceName]=i
		log("i="..i..", type="..fibaro:getType(i)..", device="..deviceName)
	else -- Add all other devices to the table
		roomID = fibaro:getRoomID(i)
		if roomID == 0 then
			roomname = "Unallocated"
		else
			roomname=string.gsub(fibaro:getRoomName(roomID), "%s+", "") -- eliminate spaces in roomname
			-- Uncomment this to eliminate all non-alphanumeric characters in roomname
			-- roomname=string.gsub(fibaro:getRoomName(roomID), "%W", "")
		end
		if jsonHome[roomname] == nil then -- Add room to the table
			jsonHome[roomname] = {}  
		end
		jsonHome[roomname][deviceName]=i
		log("i="..i..", type="..fibaro:getType(i)..", device="..deviceName..", room="..roomname)
	end
end

jHomeTable = json.encode(jsonHome)				-- ENCODES THE DATA IN JSON FORMAT BEFORE STORING
fibaro:setGlobal("HomeTable", jHomeTable) 		-- THIS STORES THE DATA IN THE VARIABLE
log("global jTable created:")					-- STANDARD DEBUG LINE TO DISPLAY A MESSAGE
log(jHomeTable)