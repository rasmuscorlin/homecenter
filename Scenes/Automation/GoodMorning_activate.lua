--[[
%% properties
%% weather
%% events
%% globals
dummy
--]]

local startSource = fibaro:getSourceTrigger();
if (
 ( tonumber(fibaro:getGlobalValue("dummy")) == tonumber("999") )
or
startSource["type"] == "other"
)
then
	fibaro:setGlobal("MorningScene", "Inactive");
end

