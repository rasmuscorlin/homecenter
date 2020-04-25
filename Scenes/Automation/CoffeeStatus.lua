--[[
%% properties
11 value
%% events
%% globals
--]]

local kaffemaskineId = 11
local kontaktKoekkenId = 224
local kontaktSpisestueId = 152
local trigger = fibaro:getSourceTrigger();

function alignState(kaffeStatus, kontaktId) 
  local kontaktStatus = fibaro:getValue(kontaktId, "value")
  if(tonumber(kaffeStatus) ~= tonumber(kontaktStatus)) then
    if(tonumber(kaffeStatus) == 0) then
      fibaro:call(kontaktId, "turnOff");
    else
      fibaro:call(kontaktId, "turnOn");
    end  
  end
end

if (tonumber(trigger['deviceID']) == kaffemaskineId
    or
	trigger["type"] == "other")
then
	local kaffeStatus = fibaro:getValue(kaffemaskineId, "value")
	alignState(kaffeStatus, kontaktKoekkenId)
	alignState(kaffeStatus, kontaktSpisestueId)
end