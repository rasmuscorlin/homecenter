--[[
%% properties
%% events
%% globals
--]]

local sourceTrigger = fibaro:getSourceTrigger();

-- Disarm alarm if it was armed by good night scene.
-- Do not disarm if presence simulator is running
if(fibaro:getGlobalValue("AlarmState") == "Armed" and 
    fibaro:getGlobalValue("HouseState") == "GoodNight") and
    tonumber(fibaro:getGlobalValue("Simu_presence")) == 0
  then
  	fibaro:debug("Setting state to disarm");
  	fibaro:setGlobal("AlarmState", "Disarm");
end

fibaro:sleep(20000);
fibaro:setGlobal("HouseState", "Default");
