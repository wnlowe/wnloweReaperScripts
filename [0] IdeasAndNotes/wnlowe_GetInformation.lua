Ifdebug = true
function Msg(variable) if Ifdebug then reaper.ShowConsoleMsg(tostring(variable) .. "\n") end end

Msg(reaper.GetTrackSendInfo_Value(reaper.GetSelectedTrack(0, 0), 0, 0, "I_SRCCHAN"))