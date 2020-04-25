--[[
%% properties
%% events
%% globals
--]]

local startSource = fibaro:getSourceTrigger();
if (
startSource["type"] == "other"
)
then
  	fibaro:call(103, "turnOff");
	fibaro:call(11, "turnOff"); --kaffemaskine
  	fibaro:call(326, "turnOff"); --strygejern
end
