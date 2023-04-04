local mode_idx = 0
local submode_idx = 0
while true do
  local mode_ret, mode_str = reaper.EnumPitchShiftModes(mode_idx)
  if not mode_ret then break end
  if mode_str and mode_str:len() > 0 then
    local continue = true
    while continue do
      local submode_str = reaper.EnumPitchShiftSubModes(mode_idx, submode_idx)
      if submode_str and submode_str:len() > 0 then 
        reaper.ShowConsoleMsg(mode_str .. " - " .. submode_str .. "\n")
        submode_idx = submode_idx + 1
      else
        submode_idx = 0
        continue = false
      end
    end
  end
  
  mode_idx = mode_idx + 1  
end