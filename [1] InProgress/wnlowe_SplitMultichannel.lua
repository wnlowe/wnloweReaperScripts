dbug = true
function Msg(variable)
    if dbug then reaper.ShowConsoleMsg(tostring (variable).."\n") end
end

itemSource = reaper.GetSelectedMediaItem(0, 0)
--Edit: Copy Items
reaper.Main_OnCommand(40698, 0)
trackSource = reaper.GetMediaItemInfo_Value(itemSource, "P_TRACK")
reaper.SetMediaTrackInfo_Value(trackSource, "I_SELECTED", 1)
idxSource = reaper.GetMediaTrackInfo_Value(trackSource, "IP_TRACKNUMBER")
takeSource = reaper.GetActiveTake(itemSource)
rawSource = reaper.GetMediaItemTake_Source( takeSource )
chanSource = reaper.GetMediaSourceNumChannels( rawSource )
tracks = {}
tracks[0] = trackSource
Msg(chanSource)
for i = 1, chanSource do
    --Track: Insert New Track
    reaper.Main_OnCommand(40001, 0)
    tracks[i] = reaper.GetTrack( 0, idxSource + i )
end

for i = 0, #tracks do
    reaper.SetMediaTrackInfo_Value(tracks[i], "I_SELECTED", 1)
end

--Track: Move tracks to new folder
reaper.Main_OnCommand(42785, 0)

reaper.SetMediaTrackInfo_Value(trackSource, "I_SELECTED", 0)

--Item: Paste items/tracks
reaper.Main_OnCommand(42398, 0)