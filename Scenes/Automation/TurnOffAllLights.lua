local houseState = fibaro:getGlobalValue("HouseState");

function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

local keepOn = Set {245, 313, 334};

-- get light id's
local ids = fibaro:getDevicesId(
  {
    interfaces = {
      "light",
    },
    properties = {
      dead = false,  
    },
    enabled = true,
    visible = true, -- optional
  }
);

-- loop through light ids
for i, id in ipairs(ids) do
    --if (fibaro:getGlobalValue("HouseState") == "GoodNight" and
    --  id == 296) -- Lys gang
  	if (houseState == "GoodNight" and keepOn[id])
    then
    	-- Skip to turn off light, and reset state
        --fibaro:debug("Skipping " .. fibaro:getName(id));
    else
    	fibaro:call(id, "turnOff");
    	--fibaro:debug("Turning off " .. fibaro:getName(id));
    end
end

-- Reset house state when lights have been turned off
--fibaro:setGlobal("HouseState", "Default");
