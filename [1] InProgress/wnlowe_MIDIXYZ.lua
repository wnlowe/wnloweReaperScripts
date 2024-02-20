Ifdebug = true
function Msg(variable) if Ifdebug then reaper.ShowConsoleMsg(tostring(variable) .. "\n") end end

Track = reaper.GetSelectedTrack(0, 0)
Msg(reaper.GetMediaTrackInfo_Value(Track, "I_RECINPUT"))
reaper.SetMediaTrackInfo_Value(Track, "I_RECMODE", 0)
-- reaper.SetMediaTrackInfo_Value(Track, "I_RECINPUT", 4096)
-- reaper.SetMediaTrackInfo_Value(Track, "I_RECARM", 1)
reaper.SetMediaTrackInfo_Value(Track, "I_RECMON", 1)
reaper.SetMediaTrackInfo_Value(Track, "B_AUTO_RECARM", 0)