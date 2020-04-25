--[[
%% properties
56 armed
398 value
%% weather
%% events
%% globals
--]]

local jT = json.decode(fibaro:getGlobalValue("HomeTable"))

local lockId = jT.Entre["Dørlåshoveddør"];
--local lockId = 393;

fibaro:debug(fibaro:getValue(lockId, "value"));

-- Turn on/off indicator light in contact at door depending on arming state of door
local startSource = fibaro:getSourceTrigger();
if (tonumber(fibaro:getValue(56, "armed")) > 0 ) then
	fibaro:call(291, "setIndicatorValue", "50");
	fibaro:call(292, "setIndicatorValue", "50");
	fibaro:call(293, "setIndicatorValue", "50");  
elseif (tonumber(fibaro:getValue(56, "armed")) == 0 ) then
	fibaro:call(291, "setIndicatorValue", "0");
	fibaro:call(292, "setIndicatorValue", "0");
	fibaro:call(293, "setIndicatorValue", "0");
end

if (tonumber(fibaro:getValue(lockId, "value")) == 1) then
	fibaro:call(290, "setIndicatorValue", "50");
else
	fibaro:call(290, "setIndicatorValue", "0");  
end

