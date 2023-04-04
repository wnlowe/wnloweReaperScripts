trackCount = reaper.CountSelectedTracks(0)
if trackCount < 1 then return end
track = reaper.GetSelectedTrack(0, 0)

trackItems = reaper.CountTrackMediaItems(track)
currentPosition = reaper.GetCursorPosition()
bestPosition = nil

for i = 0, trackItems - 1 do
    currentItem = reaper.GetTrackMediaItem(track, i)
    itemPosition = reaper.GetMediaItemInfo_Value( currentItem, "D_POSITION")
    if bestPosition == nil then
        bestPosition = itemPosition
    else
        if bestPosition < itemPosition then
            bestPosition = itemPosition
        end
    end
end

reaper.SetEditCurPos(bestPosition, true, false)
