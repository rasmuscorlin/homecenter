--[[
%% properties
%% events
249 CentralSceneEvent
221 CentralSceneEvent
205 CentralSceneEvent
%% globals
--]]

-- Get data on what was pressed
local pressSource = fibaro:getSourceTrigger()["event"]["data"];
--fibaro:debug(json.encode(pressSource)) 

-- Two key presses
if (tostring(pressSource["keyAttribute"]) == "Pressed2") then
  	if (tostring(pressSource["keyId"]) == "1") then
    
  	elseif (tostring(pressSource["keyId"]) == "2") then
    
  	elseif (tostring(pressSource["keyId"]) == "3") then
    	if (tostring(pressSource["deviceId"]) == "249") then 	-- Soveværelse
    		fibaro:startScene(50); -- Good night scene
      		fibaro:startScene(56); -- Tjek vinduer og døre
      	end
  	elseif (tostring(pressSource["keyId"]) == "4") then
    	if (tostring(pressSource["deviceId"]) == "249") then 	-- Soveværelse
    		fibaro:startScene(50); -- Good night scene
      		fibaro:startScene(56); -- Tjek vinduer og døre
      		setTimeout(function()
  					fibaro:setGlobal("AlarmState", "Arm") -- Slå alarm til
				end, 5000) -- efter 5 sekunder
      	elseif (tostring(pressSource["deviceId"]) == "221" 		-- Køkken
          or tostring(pressSource["deviceId"]) == "205") then 	-- Stue
      		fibaro:startScene(21); -- Sluk stueetage
      	end
	end
end