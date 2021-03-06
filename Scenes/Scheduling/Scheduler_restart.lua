--[[
%% properties

%% globals
--]]

local scheduleScene = 61

while (fibaro:countScenes(scheduleScene) > 0) do 
 
    fibaro:killScenes(scheduleScene); 

    fibaro:debug("Kill")
  
end; 

active =  active or { Active = 1,
  					Disabled = 2 }

activeIndex =  activeIndex or  { [1] = "Active",
  					[2] = "Disabled"}

local scheduleActive = fibaro:getGlobalValue("scheduleActive") or activeIndex[1]

if scheduleActive == activeIndex[1] then
 	-- restart a new instance if active
  	fibaro:startScene(scheduleScene)
end