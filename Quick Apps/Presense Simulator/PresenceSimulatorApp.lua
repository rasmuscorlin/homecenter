-- Settings that should be configured as app parameters on the Quick App
local Stop_Time								-- Time of day when simulation should end
local Sunset_offset							-- Number of minutes before or after sunset to activate simulation
local Random_max_duration					-- Random time of light change in minutes
local Random_max_TurnOff_duration			-- Random time to add at the stop hour+stop minute so the simulation can be more variable (0 to deactivate)
local Lights_always_on						-- IDs of lights (comma-separated) who will always stay on during Simulation
local Random_lights							-- IDs of lights (comma-separated) to use in simulation 
local Lights_On_at_end_Simulation			-- IDs of lights (comma-separated) to turn on after simulation ends (at specified Stop_hour & Stop_minute)

-- Internal variables (set automatically)
local Number_of_lights, End_simulation_time, End_simulation_time_with_random_max_TurnOff, Sunset_unix_hour, Sleep_between_TurnOff
local Is_first_launch = true
local NotifLoop = 0
local SimulationIsRunning = false
local ManualOverride
local SIMULATION_ACTIVATED = "Simulation"

local function setupUtilities(self)	
	-- Define split with global scope
	function split(s, sep)
		local fields = {}
		sep = sep or " "
		local pattern = string.format("([^%s]+)", sep)
		string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
		return fields
	end

	-- Redefine format and tostring
	local oldtostring,oldformat = tostring,string.format
	tostring = function(o)
		if type(o)=='table' then
			if o.__tostring and type(o.__tostring)=='function' then
				return o.__tostring(o)
			else
				return json.encode(o)
			end
		else
			return oldtostring(o)
		end
	end

	-- New format that uses our tostring
	string.format = function(...)
		local args = {...}
		for i=1,#args do
			if type(args[i])=='table' then
				args[i]=tostring(args[i])
			end
		end
		
		return #args > 1 and oldformat(table.unpack(args)) or args[1]
	end	
	format = string.format

	-- Helper for rounding numbers
	function Round(num, idp)
		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
	end
	
	-- List contains value
	function Contains(list, value)
		for index, val in ipairs(list) do
			if tostring(value) == tostring(val) then
				return true
			end
		end	
		return false
	end

	-- Logging
	local orgDebug = self.debug
	local logLevel = self:getVariable("LogLevel")
	LOG = { DEBUG="[DEBUG] ", INFO="[INFO] ", ERROR="[ERROR] ", HEADER="HEADER" }
	
	function Debug(...) Log(LOG.DEBUG, ...) end 
	function Info(...) Log(LOG.INFO, ...) end

	-- Creates a divining line with title
	local function logHeader(len,str)
		if #str % 2 == 1 then
			str=str.." "
		end
		local n = #str+2
		return string.rep("-",len/2-n/2).." "..str.." "..string.rep("-",len/2-n/2)
	end

	function Log(flag, ...)
		if flag == LOG.DEBUG and logLevel ~=  "debug" then
			return
		end

		local str = format(...)
		if flag == LOG.HEADER then
			str = logHeader(100, str)
		else
			str=flag..str
		end

		-- split strings with \n
		for _,s in ipairs(split(str, "\n")) do
			orgDebug(self, s)
		end 

		return str
	end
end

function QuickApp:turnOn()
	Log(LOG.HEADER, "Turning ON presence simulator")
	self:updateProperty("value", true)
	self:setVariable(SIMULATION_ACTIVATED, true)
	SimulationIsRunning = false -- Start out from clean state (not running)
	self:EndTimeCalc();
	self:MainLoop(0)
end

function QuickApp:turnOff()
	Log(LOG.HEADER, "Turning OFF presence simulator")
	self:updateProperty("value", false)
	self:setVariable(SIMULATION_ACTIVATED, false)
	SimulationIsRunning = false
	NotifLoop = 0
end

function QuickApp:onInit()
	setupUtilities(self)
	Log(LOG.HEADER, "Presense Simulator initialized")
	
	-- Load app settings
	self:LoadAppSettings()
	-- Ensure end time is pre-calculated
	self:EndTimeCalc()
	-- Start main loop
	self:MainLoop(0)
end

function QuickApp:LoadAppSettings()
	Stop_Time = self:getVariable("StopTime")
	Sunset_offset = tonumber(self:getVariable("SunsetOffset"))
	Random_max_duration = tonumber(self:getVariable("RdmMaxDuration"))
	Random_max_TurnOff_duration = tonumber(self:getVariable("MaxTurnOffDur"))
	ManualOverride = self:getVariable("ManualOverride")

	local lightsAlwaysOnString = self:getVariable("LightsAlwaysOn")
	Lights_always_on = split(lightsAlwaysOnString, ",")

	local randomLigthsString = self:getVariable("RandomLights")
	Random_lights = split(randomLigthsString, ",")
	Number_of_lights = #Random_lights

	local lightsOnAtEndOfSimulation = self:getVariable("LightsOnAtEnd")
	Lights_On_at_end_Simulation = split(lightsOnAtEndOfSimulation, ",")
end

function QuickApp:UnixTimeCalc(converted_var, hour, min)
	local time = os.time();
	local date = os.date("*t", time);
	local year = date.year;
	local month = date.month;
	local day = date.day;
	unix_hour = os.time{year=year, month=month, day=day, hour=hour, min=min, sec=sec};
	Debug("Converted "..converted_var..": "..hour..":"..min.." to Unix Time: "..unix_hour..")")
	return unix_hour
end

function QuickApp:ReverseUnixTimeCalc(converted_var,hour)
	reverse_unix = os.date("%H:%M", hour)
	Debug("Reverse converted Unix Time of "..converted_var.." : "..hour.." To: "..reverse_unix)
	return reverse_unix
end

function QuickApp:EndTimeCalc()
	local stopHour, stopMin;
	local stopHour = tonumber(string.sub(Stop_Time, 1 , 2));
	local stopMin = tonumber(string.sub(Stop_Time, 4));

	-- Generate End_simulation_time (changes at midnight) will not change during Simulation, only when ended
	End_simulation_time = self:UnixTimeCalc("Original planed End_simulation_time", stopHour, stopMin)

	local sunsetHour = fibaro.getValue(1,'sunsetHour');
	local hour = string.sub(sunsetHour, 1 , 2);
	local min = string.sub(sunsetHour, 4);
	Sunset_unix_hour = self:UnixTimeCalc("Sunset", hour, min) + Sunset_offset*60;

	-- If stop hour is between 00 and 12h then add 24 hours to End_simulation_time
	if tonumber(stopHour) <= 12 and (os.time() >= End_simulation_time) then
		End_simulation_time = End_simulation_time + 24*60*60
		Debug("Stop hour <= 12, Added 24H to End_simulation_time (End_simulation_time is ending after midnignt)");
		Debug("New End_simulation_time: "..End_simulation_time);
	end 

	if Random_max_TurnOff_duration ~= 0 and Number_of_lights > 1 then -- if Simulation = 1 then slow turn off, else turn off all immediately
		Sleep_between_TurnOff = Round((math.random(Random_max_TurnOff_duration)/(Number_of_lights-1)),1);
		Sleep_between_TurnOff = math.random(Random_max_TurnOff_duration)/(Number_of_lights-1);
		Debug("Calculated sleeping between each turn off: "..Sleep_between_TurnOff.." min");
	else
		Sleep_between_TurnOff = 0;
		Debug("No sleeping between turn off");
	end
	
	End_simulation_time_with_random_max_TurnOff = End_simulation_time + ((Sleep_between_TurnOff*(Number_of_lights-1))*60)

	-- If calculation is done between midnight and End_simulation_time and sunset is wrongly calculated after endtime (at first start only)
	if ((os.time() < End_simulation_time) and (Sunset_unix_hour - End_simulation_time > 0) and (Is_first_launch == true)) then 
		Sunset_unix_hour = Sunset_unix_hour - (24*60*60) + 70; -- remove 24h58m50s of sunsettime
		Debug("Launch after Midnight and before End_simulation_time, removed 24H to Sunset_unix_hour (Only at the first start)");
		Debug("New SunsetTime: "..Sunset_unix_hour);
	end

	Is_first_launch = false
end

function QuickApp:TurnOffDevice(deviceId)
	fibaro.call(tonumber(deviceId), "turnOff");
	local name = fibaro.getName(deviceId);
	if (name == nil or name == string.char(0)) then
		name = "Unknown"
	end
	Debug("Device: "..name.." Off")
end

function QuickApp:TurnOffGroup(group, keepEndSimLigthsOn)
	local simulationIsActivated = self:getVariable(SIMULATION_ACTIVATED)

	local ID_devices_group = group
	if ID_devices_group ~= 0 then 
		-- If Simulation ended before End_simulation_time, then no turn off delay
		if simulationIsActivated == false then
			Sleep_between_TurnOff = 0
		end

		for i=1, #ID_devices_group do
			local deviceId = tonumber(ID_devices_group[i])
			if Contains(Lights_On_at_end_Simulation, deviceId) == false then
				local timeToSleepBeforeTurnOff = Sleep_between_TurnOff * (i - 1)
				
				-- Wait Number of lights -1 (do not need to wait for the first TurnOff)
				if i > 1 then 
					Debug("Sleeping "..timeToSleepBeforeTurnOff.." minute(s) before turning off device "..deviceId);
				end

				fibaro.setTimeout(timeToSleepBeforeTurnOff*60000, function()
					self:TurnOffDevice(deviceId) 
				end)
			end
		end
	end
end

function QuickApp:TurnOnGroup(group)
	for i=1, #group do 
		local id = tonumber(group[i]); 
		fibaro.call(id, "turnOn"); 
		local name = fibaro.getName(id); 
		if (name == nil or name == string.char(0)) then 
			name = "Unknown" 	
		end 
		Debug("Device: "..name.." turned On "); 
	end
end

function QuickApp:TurnOnAlwaysOnLights()
	if Lights_always_on[1] ~= nil then
		Debug("Turning on Always_On lights:");
		self:TurnOnGroup(Lights_always_on)
	end
end

function QuickApp:EndSimulation()
	Log(LOG.HEADER, "Ending presence simulation");

	SimulationIsRunning = false

	if #Random_lights > 0 then
		Debug("Turn OFF simulation lights")
		self:TurnOffGroup(Random_lights)
	end
	if #Lights_always_on > 0 then
		Debug("Turn OFF Always_On lights")
		self:TurnOffGroup(Lights_always_on)
	end
	if #Lights_On_at_end_Simulation > 0 then
		Debug("Turn ON ligths that should be on after simulation")
		self:TurnOnGroup(Lights_On_at_end_Simulation)
	end

	local simulationIsActivated = self:getVariable(SIMULATION_ACTIVATED)
	if simulationIsActivated then
		Info("Presence Simulation will restart tomorrow.")
		Info("Sunset is around "..fibaro.getValue(1, "sunsetHour").." + Sunset Shift of "..Sunset_offset.."min = Start Time around "..self:ReverseUnixTimeCalc("Sunset unix time", Sunset_unix_hour))
	end
	NotifLoop = 0 -- will force main loop notifications at end of simulation
end

function QuickApp:IsSimulationRunning()
	local simulation = self:getVariable(SIMULATION_ACTIVATED)
	return (simulation and os.time() <= End_simulation_time) or ManualOverride
end

function QuickApp:IsSimulationActive()
	local simulation = self:getVariable(SIMULATION_ACTIVATED)
	return (simulation and os.time() <= End_simulation_time) or ManualOverride
end

function QuickApp:IsEndSimulationTimeSetForToday()
	local endSimulationDay = os.date("%d", End_simulation_time)
	local today = os.date("%d", os.time())
	return endSimulationDay == today
end

-- Presence Simulation actions Main loop
function QuickApp:SimulatePresence()
	-- Check if simulation is active - else simply return to cancel the loop
	if self:IsSimulationActive() == false or SimulationIsRunning == false then
		Info("Cancelling the active simulation loop.")
		return;
	end
	
	-- Select random light to update state on
	local random_light = tonumber(Random_lights[math.random(Number_of_lights)])
	Debug("Updating status for light "..random_light)

	-- Get the value of the random light in the list
	local lightTurnedOn = fibaro.getValue(random_light, 'value')

	-- Turn on the light if off or turn off if on
	if lightTurnedOn then
		fibaro.call(random_light, "turnOff")
	else
		fibaro.call(random_light, "turnOn")
	end
	
	-- Calculate random sleep time
	local sleepTime = math.random(Random_max_duration*60000)
	Info("Sleeping for "..Round(sleepTime/60000,2).." minutes before next status change");
	fibaro.setTimeout(sleepTime, function()
		self:SimulatePresence()
	end)
end

-- Main loop that check if simulation should be started or stopped
function QuickApp:MainLoop(notifLoopCounter)
	local simulationIsTurnedOn = self:getVariable(SIMULATION_ACTIVATED)

	-- Check if the end time needs to be recalculated
	if self:IsEndSimulationTimeSetForToday() == false then
		Debug("Re-calculating end-time")
		self:EndTimeCalc()
	end
	
	-- If simulation is not active cancel the main loop - no need to proceed (Loop will be re-activated on init or when the simulator is turned on)
	if simulationIsTurnedOn == false then
		if SimulationIsRunning then
			self:EndSimulation()
		end

		return -- Break loop
	end

	-- define if nighttime (sunset = 1)
	if os.time() >= Sunset_unix_hour then
		sunset = 1 
	else 
		sunset = 0 
	end 

	-- Activate simulation
	if simulationIsTurnedOn then
		if SimulationIsRunning == false then
			if sunset == 1 and (os.time() <= End_simulation_time) then 
				Log(LOG.HEADER, "It's sunset time -> Simulation ON")
				SimulationIsRunning = true
				self:TurnOnAlwaysOnLights()
				self:SimulatePresence()
			elseif ManualOverride == "true" then 
				Log(LOG.HEADER, "Manual Override Activated -> Simulation ON")
				SimulationIsRunning = true
				self:TurnOnAlwaysOnLights()
				self:SimulatePresence()
			end
		else
			-- Simulation is running - check if end-time has passed
			if sunset == 1 and (os.time() >= End_simulation_time) then 
				self:EndSimulation()
			end
		end
	end

	-- Write status info at intervals
	if ManualOverride == "false" and sunset == 0 and notifLoopCounter == 0 then 
		Debug("Sunset is at "..fibaro.getValue(1, "sunsetHour").." + Sunset shift of "..Sunset_offset.."min = Start Time at "..QuickApp:ReverseUnixTimeCalc("Sunset unix time", Sunset_unix_hour));
		Debug("End of Simulation: "..self:ReverseUnixTimeCalc("End Simulation", End_simulation_time).." + random of "..Random_max_TurnOff_duration.."min = "..self:ReverseUnixTimeCalc("End Simulation", End_simulation_time_with_random_max_TurnOff));
	end

	-- Counter to keep track of when to 
	if notifLoopCounter <= 120 then
		if notifLoopCounter == 120 then
			notifLoopCounter = 0
		end
		if notifLoopCounter == 0 then
			Info("Now, checking for actions every minute. Next notify: in 2 hours");
		end
	end

	-- Call loop every minute
	fibaro.setTimeout(1000*60, function()
		self:MainLoop(notifLoopCounter + 1)
	end)
end