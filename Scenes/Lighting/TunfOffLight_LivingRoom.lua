--[[
%% properties
206 value
%% weather
%% events
%% globals
--]]

local startSource = fibaro:getSourceTrigger();
if (
 ( tonumber(fibaro:getValue(206, "value")) == 0 )
or
startSource["type"] == "other"
)
then
	fibaro:call(30, "turnOff");
	fibaro:call(105, "turnOff");
	fibaro:call(107, "turnOff");
	fibaro:call(475, "turnOff");
end

