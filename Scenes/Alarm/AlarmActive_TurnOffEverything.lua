--[[
%% properties
28 armed
%% weather
%% events
%% globals
--]]

local startSource = fibaro:getSourceTrigger();
if (
 ( tonumber(fibaro:getValue(28, "armed")) > 0 )
or
startSource["type"] == "other"
)
then
	fibaro:setGlobal("MorningScene", "Inactive");
	setTimeout(function()
		fibaro:startScene(39);
	end, 5000)
end

