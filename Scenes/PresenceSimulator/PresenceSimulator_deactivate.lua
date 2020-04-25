--[[
%% properties
293 value
%% events
%% globals
--]]

local startSource = fibaro:getSourceTrigger();
if (
 ( tonumber(fibaro:getValue(293, "value")) == 0 )
or
startSource["type"] == "other"
)
then
	fibaro:setGlobal("Simu_presence", "0");
end

