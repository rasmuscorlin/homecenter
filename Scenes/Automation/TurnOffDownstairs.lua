--[[
%% properties
%% events
%% globals
--]]

local trigger = fibaro:getSourceTrigger();

if (tonumber(fibaro:getGlobalValue("dummy")) == 999
  or
    trigger["type"] == "other"
  )
then
    local jT = json.decode(fibaro:getGlobalValue("HomeTable"));

    -- Sluk lys og kaffemaskine
	fibaro:call(jT["Køkken"]["Lyskøkken"], "turnOff");
	fibaro:call(jT["Spisestue"]["Lysspisestue"], "turnOff");
  	fibaro:call(jT["Spisestue"]["Lampeskænk"], "turnOff");
	fibaro:call(jT["Stue"]["Loftslampestue"], "turnOff");
  	fibaro:call(jT["Stue"]["Standerlampeterrass"], "turnOff");
  	fibaro:call(jT["Stue"]["Standerlampestol"], "turnOff");
  	fibaro:call(jT["Stue"]["Standerlampetv"], "turnOff");
  	fibaro:call(jT["Gangstuen"]["Lysgangstuen"], "turnOff");
  	fibaro:call(jT["Bryggers"]["Lysbryggers"], "turnOff");
  	fibaro:call(jT["Køkken"]["Coffeemachine"], "turnOff");
  	fibaro:call(jT["Viktualierum"]["Lysviktualierum"], "turnOff");
  	fibaro:call(jT["Badeværelsestuen"]["Lysbadeværelse"], "turnOff");

  	-- Sluk musik og TV
	fibaro:startScene(35); -- sluk musik
  
      -- Nulstil kontakter
  	fibaro:call(206, "turnOff"); -- kontakt stue
	fibaro:call(207, "turnOff");
  	fibaro:call(208, "turnOff");
  	fibaro:call(209, "turnOff");
  	fibaro:call(523, "turnOff"); -- kontakt køkken
	fibaro:call(524, "turnOff");
  	fibaro:call(525, "turnOff");
  	fibaro:call(150, "turnOff"); -- kontakt spisestue
	fibaro:call(151, "turnOff");
  	fibaro:call(152, "turnOff");
end
