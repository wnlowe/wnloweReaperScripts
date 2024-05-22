Ifdebug = false
function Msg(variable) if Ifdebug then reaper.ShowConsoleMsg(tostring(variable) .. "\n") end end

retval, tracknumber, itemnumber, fxnumber = reaper.GetFocusedFX()

dest_fx = 

reaper.TrackFX_CopyToTrack( tracknumber, fxnumber, tracknumber, dest_fx, true )
reaper.TrackFX_SetPinMappings( tracknumber, dest_fx, isoutput, pin, low32bits, hi32bits )
reaper.TrackFX_CopyToTrack( tracknumber, fxnumber, tracknumber, dest_fx + 1, false )

--to address the third item in the container at the second position of the track FX chain for tr, the index would be 0x2000000 + 3*(TrackFX_GetCount(tr)+1) + 2
retval, buf = reaper.TrackFX_GetNamedConfigParm( track, fx, parmname )