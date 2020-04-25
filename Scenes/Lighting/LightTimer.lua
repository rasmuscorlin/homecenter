--[[
%% properties
200 value
15 value
320 value
387 value
%% events
%% globals
--]]

-- Configuration --
local startSource = fibaro:getSourceTrigger()
local sensorId = startSource['deviceID']
local lightId, turnOffSceneId

local jT = json.decode(fibaro:getGlobalValue("HomeTable"));

if(tonumber(sensorId) == jT["Badeværelsestuen"]["Motionsensorbad"]) then -- badeværelse stuen
	lightId = jT["Badeværelsestuen"]["Lysbadeværelse"];
	turnOffSceneId = 33;
elseif(tonumber(sensorId) == jT["Badeværelse1.sal"]["Bevægelsebad1st"]) then -- badeværelse 1. sal
	lightId = jT["Badeværelse1.sal"]["Lysbad1.sal"];
	turnOffSceneId = 40;
elseif(tonumber(sensorId) == jT["Viktualierum"]["Bevægelsevikt"]) then -- viktualierum
	lightId = jT["Viktualierum"]["Lyssensorvikt"]; -- Lys viktualierum
	turnOffSceneId = 30;
--elseif(tonumber(sensorId) == 387) then -- bryggers
--	lightId = 379
--	turnOffSceneId = 70
else 
	fibaro:abort()
end
-- Configuration end --

fibaro:debug(fibaro:getValue(sensorId, "value"));

if ((tonumber(fibaro:getValue(sensorId, "value")) >= 0 )
	or
	startSource["type"] == "other"
	)
then
	if(fibaro:countScenes(turnOffSceneId) > 0) then
    	fibaro:killScenes(turnOffSceneId) -- Turn of ligths timer
    end
  	
	if(tonumber(fibaro:getValue(sensorId, "value")) > 0) then
  		--if(tonumber(fibaro:getValue(lightId, "value")) == 0) then
    		fibaro:debug(lightId)
			fibaro:call(lightId, "turnOn") -- Turn on lights
        --end
    else
  		--if(tonumber(fibaro:getValue(lightId, "value")) == 1) then 
			fibaro:startScene(turnOffSceneId) -- Turn of lights timer
        --end
    end
end

