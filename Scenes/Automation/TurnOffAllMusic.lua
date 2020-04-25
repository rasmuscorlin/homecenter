--[[
%% properties
%% events
%% globals
--]]

--local heosDevices = {139, 258, 259, 260}
local heosDevices = fibaro:getDevicesId(
  {
    type = "com.fibaro.denonHeosZone",
    properties = {
      dead = false,  
    },
    enabled = true,
  }
);


for index, deviceId in ipairs(heosDevices) 
do
    fibaro:debug("Turning off " .. fibaro:getName(deviceId));
	fibaro:call(tonumber(deviceId), "pause")
end

