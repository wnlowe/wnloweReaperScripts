timeStart, timeEnd = reaper.GetSet_LoopTimeRange( false, false, 0, 0, true )
numSelected = reaper.CountSelectedMediaItems(0)
if numSelected < 1 then return end
selectedItems = {}
for i = 0, numSelected - 1 do
    item = reaper.GetSelectedMediaItem(0, i)
    table.insert(selectedItems, item)
end
for j = 1, #selectedItems do
    item = selectedItems[j]
    itemStart =  reaper.GetMediaItemInfo_Value( item, "D_POSITION")
    itemEnd = itemStart +  reaper.GetMediaItemInfo_Value( item, "D_LENGTH")
    if itemStart > timeStart or itemEnd < timeEnd then goto continue end
    newItem = reaper.SplitMediaItem(item, timeStart)
    lastItem = reaper.SplitMediaItem(newItem, timeEnd)
    track = reaper.GetMediaItem_Track(newItem)
    reaper.DeleteTrackMediaItem(track, newItem)
    reaper.SetMediaItemInfo_Value(lastItem, "D_POSITION", timeStart)
    reaper.SetMediaItemSelected( item, true )
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_CROSSFADE"), 0)
    reaper.Main_OnCommand(40020, 0)
    reaper.SelectAllMediaItems( 0, false )
    ::continue::
end
