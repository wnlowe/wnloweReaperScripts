Ifdebug = true
function Msg(variable) if Ifdebug then reaper.ShowConsoleMsg(tostring(variable) .. "\n") end end

Track = reaper.GetSelectedTrack(0, 0)
FXIdx = reaper.TrackFX_GetByName( Track, "Pigments", false )
reaper.TrackFX_SetPreset( Track, FXIdx, "AudioIn" )

reaper.SetMediaTrackInfo_Value(Track, "I_RECARM", 1)
reaper.SetMediaTrackInfo_Value(Track, "I_RECMON", 2)
reaper.SetMediaTrackInfo_Value(Track, "I_RECMODE", 1)
reaper.SetMediaTrackInfo_Value(Track, "I_RECMODE_FLAGS", 2)
reaper.SetMediaTrackInfo_Value(Track, "B_AUTO_RECARM", 0)