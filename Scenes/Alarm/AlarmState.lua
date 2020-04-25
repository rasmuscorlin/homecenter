--[[
%% properties
%% events
%% globals
AlarmState
--]]

function getDoorsAndWindows()
    local doors = fibaro:getDevicesId(
      {
        type = "com.fibaro.doorSensor",
        properties = {
        --  dead = false,  
        },
        enabled = true,
        visible = true, -- optional
      }
    );
  
    local windows = fibaro:getDevicesId(
      {
        type = "com.fibaro.windowSensor",
        properties = {
        --  dead = false,  
        },
        enabled = true,
        visible = true, -- optional
      }
    );
  
    local allSensors = windows;
    for _, v in pairs(doors) do
        table.insert(allSensors, v)
    end
    return allSensors;
  end
  
  
  --fibaro:debug("Running");
  
  local alarmState = fibaro:getGlobalValue("AlarmState");
  
  --if(tonumber(fibaro:getValue(120, "value")) == 1) then
  if(alarmState == "Arm") then
    --fibaro:debug("Arming");
  
    local ids = getDoorsAndWindows();
    -- loop through ids
    for i, id in ipairs(ids) do
      fibaro:call(id, "setArmed", "1")
      --fibaro:debug(fibaro:getName(id));
    end
  
    fibaro:setGlobal("AlarmState", "Armed")  
  
  elseif(alarmState == "Disarm") then
    --fibaro:debug("Disarming");  
  
    local ids = getDoorsAndWindows();
    -- loop through ids
    for i, id in ipairs(ids) do
      fibaro:call(id, "setArmed", "0")
      --fibaro:debug(fibaro:getName(id));
    end
  
    fibaro:setGlobal("AlarmState", "Disarmed")  
  end
  
  