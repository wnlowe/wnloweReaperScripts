-- define the command IDs for the actions you want to switch between
local COMMAND_ID_1 = 41305
local COMMAND_ID_2 = "_671786c1c170467996f63c084ba4c807"

-- get the current state of the hotkey
local hotkey_state = reaper.GetToggleCommandStateEx(0, COMMAND_ID_1)

-- if the hotkey is currently set to run COMMAND_ID_1, set it to run COMMAND_ID_2 instead
if hotkey_state == 1 then
  reaper.SetToggleCommandState(0, COMMAND_ID_2, 1)
  
  -- turn off COMMAND_ID_1
  reaper.SetToggleCommandState(0, COMMAND_ID_1, 0)
else
  -- if the hotkey is currently set to run COMMAND_ID_2, set it to run COMMAND_ID_1 instead
  reaper.SetToggleCommandState(0, COMMAND_ID_1, 1)
  
  -- turn off COMMAND_ID_2
  reaper.SetToggleCommandState(0, COMMAND_ID_2, 0)
end