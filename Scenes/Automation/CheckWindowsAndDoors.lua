--[[
%% properties
%% globals 
--]]

--[[
---------------------------------------------
-- CHECK DOOR/WINDOWS FOR OPEN/CLOSE STATE --
---------------------------------------------
Copyright © 2016 by Zoran Sankovic - Sankotronic
Version 1.0

This scene will be triggered when any door or window is opened or closed if
its ID is added above in scene header %% properties section and will send you
push notification which one. If it is run manually or started with RUN button
or called by VD or other scene then it will check all doors and windows that
are added in winDoorID table variable and send you a popup message with the
list of all doors and windows openned.

This scene requires following global variables:
DoorWinCheck - values: "Yes", "No" - set by VD
You can enter name of your variable for that purpouse and even map your
values to work properly.
--]]

-- PART OF CODE FOR USERS TO EDIT AND SETUP ---------------------------------
-- GLOBAL VARIABLES -- enter names and value mapping of your global variables 
-- or leave as it is and add to variables panel
-- enter name of your global variable and map values
local doorWinCheck   = "DoorWinCheck";
local doorWinMapping = {Yes="Yes", No="No"};

-- SENSORS, USERS, NOTIFICATIONS setup --------------------------------------
-- enter in this table IDs of all window and door sensors separated by comma
-- that you want to be checked when scene is started manually or by another 
-- scene or VD
local winDoorID   = {50, 52, 179, 28, 46, 48, 171, 159, 163, 155, 157, 173, 177, 498};
local lockID = {393};
-- define users to send push messages, replace with your user ID
local userID              = {314};
-- flag for each user; if 1 then send notifications else if 0 do not send notifications
local userFlag            = {1};
-- setup local variables for notifications
-- popup notification title
local popupTitle            = "Door/Window status";
-- opoup notification subtitle usually contain time when is sent
local popupSubtitle         = "%H:%M:%S | %d.%m.%Y.";
-- message if found any door or window opened
local foundOpenedMessage    = "Following doors/windows are open:";
-- message if found all doors/windows closed
local foundAllClosedMessage = "All doors/windows are closed!";
-- text for button to close popup notification
local buttonCaption         = "OK";
-- url path to icon to show on popup message
local imgUrl                = ""

-- DEBUGGING VARIABLES ---------------------------------------------------
-- setup debugging, true is turned on, false turned off.
local deBug         = true;
-- DEFINE FLAGS - in this section add code to change users flags -----------------

-- END OF CODE PART FOR USERS TO EDIT AND SETUP --------------------------

-- BELLOW CODE NO NEED TO MODIFY BY USER ---------------------------------
local OpenWinDoor   = " ";
local opened        = false;
local sourceTrigger = fibaro:getSourceTrigger();
local doorWin       = fibaro:getGlobalValue(doorWinCheck);

-- send push notifications!
function sendPush(message)
  if #userID > 0 then
    for i = 1, #userID do
      if userFlag[i] == 1 then
        fibaro:debug("Sending push to " .. userID[i] .. " " .. message);
        fibaro:call(userID[i], "sendPush", message); -- Send message to flagged users
      end
    end
  end
end

function sendPopup(open, Info)
  local typeInfo;
  local titleInfo;
  
  if open then
    typeInfo = "Warning";
    titleInfo = foundOpenedMessage;
  else  
    typeInfo = "Success";
    titleInfo = foundAllClosedMessage;
  end

  if deBug then fibaro:debug(titleInfo); end
  
  ------------------------------------- POPUP MESSAGE
  HomeCenter.PopupService.publish({
      -- title (required)
      title = popupTitle,
      -- subtitle(optional), e.g. time and date of the pop-up call
      subtitle = os.date(popupSubtitle),
      -- content header (optional)
      contentTitle = titleInfo,
      -- content (required)
      contentBody = Info,
      -- notification image (assigned from the variable)
      img = "",
      -- type of the pop-up
      type = typeInfo,
      -- buttons definition
      buttons = { { caption = buttonCaption, sceneId = 0 } }
    })
end

if (sourceTrigger["type"] == "property") then
  if (doorWin == doorWinMapping.Yes) then
    local WinDoorID = tonumber(sourceTrigger['deviceID'])
    local status = tonumber(fibaro:getValue(WinDoorID, "value"))
    if (status == 1) then
      local room       = fibaro:getRoomNameByDeviceID(WinDoorID);
      local deviceName = fibaro:getName(WinDoorID);
      if deBug then fibaro:debug(room..' ' .. deviceName .. ' is opened.') end
      local pushMessage = room..' ' .. deviceName .. ' is opened.'
      sendPush(pushMessage);
    else
      local deviceName = fibaro:getName(WinDoorID);
      local room       = fibaro:getRoomNameByDeviceID(WinDoorID);
      if deBug then fibaro:debug(room..' ' .. deviceName .. ' is closed.') end
    end
  end
elseif (sourceTrigger["type"] == "other") then
  for i = 1, #winDoorID do
    if tonumber(fibaro:getValue(winDoorID[i], "value")) == 1 then
      opened = true;
      OpenWinDoor = OpenWinDoor .. fibaro:getRoomNameByDeviceID(winDoorID[i]) .." ".. fibaro:getName(winDoorID[i]) .. "\n";
      if deBug then fibaro:debug("It is open: "..fibaro:getRoomNameByDeviceID(winDoorID[i]) .." ".. fibaro:getName(winDoorID[i])) end
    end
  end 
  for i = 1, #lockID do
    if tonumber(fibaro:getValue(lockID[i], "value")) == 0 then
      opened = true;
      OpenWinDoor = OpenWinDoor .. fibaro:getRoomNameByDeviceID(lockID[i]) .." ".. fibaro:getName(lockID[i]) .. "\n";
      if deBug then fibaro:debug("It is open: "..fibaro:getRoomNameByDeviceID(lockID[i]) .." ".. fibaro:getName(lockID[i])) end
    end
  end 
  
  if opened then 
    sendPush(foundOpenedMessage)
    sendPopup(opened, OpenWinDoor);
  end
end
fibaro:abort();