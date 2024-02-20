Ifdebug = false
function Msg(variable) if Ifdebug then reaper.ShowConsoleMsg(tostring(variable) .. "\n") end end

function AddSend()
    SendIdx = reaper.CreateTrackSend(SourceTrack, SelTrack)
    local rtn =  reaper.SetTrackSendInfo_Value( SourceTrack, 0, SendIdx, "I_SRCCHAN", -1 )
end

NumTracks = reaper.CountTracks(0)

for i = 1, NumTracks - 1 do
    local retval, buf = reaper.GetTrackName( reaper.GetTrack( 0, i ) )
    if buf == "Roli Control" then
        SourceTrack = reaper.GetTrack(0, i)
        goto continue
    end
end

::continue::
local  retval, tracknumber, fxnumber, paramnumber = reaper.GetLastTouchedFX()
SelTrack = reaper.GetTrack(0, tracknumber - 1)

NumSend =  reaper.GetTrackNumSends( SourceTrack, 0 )
notFound = true
for j = 0, NumSend - 1 do
    local dt = reaper.GetTrackSendInfo_Value( SourceTrack, 0, j, "P_DESTTRACK" )
    if dt == SelTrack then
        notFound = false
    end
end
if notFound then AddSend() end

parmname = 'param.' .. paramnumber .. '.plink.active'
local ret = reaper.TrackFX_SetNamedConfigParm( SelTrack, fxnumber, parmname, 1 )
parmname = 'param.' .. paramnumber .. '.plink.effect'
local ret = reaper.TrackFX_SetNamedConfigParm( SelTrack, fxnumber, parmname, -100 )
parmname = 'param.' .. paramnumber .. '.plink.midi_msg'
local ret3 = reaper.TrackFX_SetNamedConfigParm( SelTrack, fxnumber, parmname, 176 )
parmname = 'param.' .. paramnumber .. '.plink.midi_msg2'
local ret = reaper.TrackFX_SetNamedConfigParm( SelTrack, fxnumber, parmname, 148 )