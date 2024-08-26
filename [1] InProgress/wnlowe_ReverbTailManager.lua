function Msg(variable)
    dbug = true
    if dbug then reaper.ShowConsoleMsg(tostring (variable).."\n") end
end

Item = reaper.GetSelectedMediaItem(0, 0)

Track = reaper.GetSelectedTrack(0, 0)
ParentTrack = reaper.GetParentTrack(Track)
Start = reaper.GetMediaItemInfo_Value(Item, "D_POSITION ")
Msg(Start)
End = reaper.GetMediaItemInfo_Value(Item, "D_LENGTH ") + Start
Msg(End)
VolumeEnvelope = reaper.GetTrackEnvelopeByName( ParentTrack, "Volume" )
StartValue = reaper.GetEnvelopePointByTime( VolumeEnvelope, Start )
Msg(StartValue)
reaper.InsertEnvelopePoint( VolumeEnvelope, Start, StartValue, 1, 0, false, true )
reaper.InsertEnvelopePoint( VolumeEnvelope, End, -200, 1, 0, false, true )
reaper.InsertEnvelopePoint( VolumeEnvelope, End + 0.1, -200, 1, 0, false, true )
reaper.InsertEnvelopePoint( VolumeEnvelope, End + 0.2, StartValue, 1, 0, false, true )
reaper.Envelope_SortPoints( VolumeEnvelope )