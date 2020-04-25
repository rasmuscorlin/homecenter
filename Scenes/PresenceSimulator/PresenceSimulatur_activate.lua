--[[
%% properties
%% events
%% globals
--]]

local startSource = fibaro:getSourceTrigger();
if ( startSource["type"] == "other" )
then
	fibaro:setGlobal("Simu_presence", "1");
end

