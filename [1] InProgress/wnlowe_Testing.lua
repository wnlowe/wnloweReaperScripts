Ifdebug = true
function Msg(variable) if Ifdebug then reaper.ShowConsoleMsg(tostring(variable) .. "\n") end end

track = reaper.GetSelectedTrack(0, 0)
local  retval, tracknumber, fxnumber, paramnumber = reaper.GetLastTouchedFX()
Msg(fxnumber)
param = 'param.' .. paramnumber .. '.plink.midi_msg'
Msg(param)
ret, buf = reaper.TrackFX_GetNamedConfigParm(track, fxnumber, param)
if ret then Msg("A") else Msg("B") end
Msg(buf)