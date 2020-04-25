--[[
%% properties
498 value
498 armed
%% weather
%% events
%% globals
--]]

local startSource = fibaro:getSourceTrigger();
if ( -- Hoveddør åbne og alarm slået til
 ( (tonumber(fibaro:getValue(498, "value")) > 0 and tonumber(fibaro:getValue(498, "armed")) > 0) )
or
startSource["type"] == "other"
)
then
	fibaro:call(429, "turnOn"); -- Lys entre
  	fibaro:call(379, "turnOn"); -- Lys bryggers
	fibaro:call(296, "turnOn"); -- Lys gang (øvre)
	--fibaro:call(142, "turnOn"); -- Lys køkken
	fibaro:call(149, "turnOn"); -- Lys spisestue
	--fibaro:call(103, "turnOn"); -- Strøm til TV
	fibaro:setGlobal("Simu_presence", "0"); -- Slå presence sim fra
	fibaro:setGlobal("scheduleActive", "Active"); -- Aktiver shceduler
end


