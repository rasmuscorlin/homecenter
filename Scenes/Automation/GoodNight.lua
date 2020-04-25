--[[
%% properties
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
  	-- Sæt state til godnat
  	fibaro:setGlobal("HouseState", "GoodNight")
  
    -- Luk ned
	fibaro:startScene(51); -- sluk enheder (strygejern, o.lign.)
	fibaro:startScene(35); -- sluk musik
  	fibaro:startScene(37); -- sluk lys
    
	fibaro:call(245, "setValue", "10"); -- Tænd lys soveværelse
	setTimeout(function() -- sluk lys soveværelse efter 1 min
		fibaro:call(245, "turnOff");
	end, 60000)
end
