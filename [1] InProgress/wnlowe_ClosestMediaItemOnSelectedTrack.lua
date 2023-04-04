trackCount = reaper.CountSelectedTracks(0)
if trackCount < 1 then return end
track = reaper.GetSelectedTrack(0, 0)

trackItems = reaper.CountTrackMediaItems(track)
currentPosition = reaper.GetCursorPosition()
BestDistance, bestPosition = nil

for i = 0, trackItems - 1 do
    currentItem = reaper.GetTrackMediaItem(track, i)
    itemPosition = reaper.GetMediaItemInfo_Value( currentItem, "D_POSITION")
    currentDistance = math.abs(currentPosition - itemPosition)
    if BestDistance == nil then
        BestDistance = currentDistance
        bestPosition = itemPosition
        bestItem = currentItem
    else
        if BestDistance > currentDistance then
            BestDistance = currentDistance
            bestPosition = itemPosition
            bestItem = currentItem
        end
    end
end

reaper.SetEditCurPos(bestPosition, true, false)
