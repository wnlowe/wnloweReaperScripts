SendTrack = reaper.GetSelectedTrack(0, 0)
RecieveName = "FOA Viz"
RecieveTrack = nil

for i = 0, reaper.GetNumTracks() do
    local track = reaper.GetTrack(0, i)
    local r, trackName = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    if trackName == RecieveName then
        RecieveTrack = track
        goto continue
    end
end

::continue::

if RecieveTrack ~= nil then SendIdx = reaper.CreateTrackSend(SendTrack, RecieveTrack) end

reaper.SetTrackSendInfo_Value( SendTrack, 0, SendIdx, "D_VOL", 1 )
reaper.SetTrackSendInfo_Value( SendTrack, 0, SendIdx, "I_SRCCHAN", 2048)
reaper.SetTrackSendInfo_Value( SendTrack, 0, SendIdx, "I_DSTCHAN", 0)