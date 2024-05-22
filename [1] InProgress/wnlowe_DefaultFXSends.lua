Ifdebug = false
function Msg(variable) if Ifdebug then reaper.ShowConsoleMsg(tostring(variable) .. "\n") end end

NumTracks =  reaper.GetNumTracks()
DestTrackDelay = nil
DestTrackVerb = nil
for i = 0, NumTracks - 1 do
    local thisTrack = reaper.GetTrack( 0, i )
    retval, TrackName = reaper.GetTrackName(  thisTrack )
    if TrackName == "FX VERB" then DestTrackVerb = thisTrack
    elseif TrackName == "FX DELAY" then DestTrackDelay = thisTrack
    end
    if DestTrackDelay ~= nil and DestTrackVerb ~= nil then goto nextSection end
end

::nextSection::
MediaTrack = reaper.GetSelectedTrack(0, 0)
SendIdxVerb = reaper.CreateTrackSend( MediaTrack, DestTrackVerb )
SendIdxDelay = reaper.CreateTrackSend( MediaTrack, DestTrackDelay )
if SendIdxVerb > -1 then reaper.SetTrackSendInfo_Value( MediaTrack, 0, SendIdxVerb, "D_VOL", 0 )
else Msg(SendIdxDelay) end
if SendIdxDelay > -1 then reaper.SetTrackSendInfo_Value( MediaTrack, 0, SendIdxDelay, "D_VOL", 0 )
else Msg("1") end