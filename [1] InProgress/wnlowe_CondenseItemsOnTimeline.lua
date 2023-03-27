reaper.Undo_BeginBlock()
totalItems = reaper.CountSelectedMediaItems()
endTime = 0
for i = 0, totalItems - 1 do
    item = reaper.GetSelectedMediaItem(0, i)
    reaper.SetMediaItemInfo_Value(item, "D_POSITION", endTime)
    length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    endTime = endTime + length
end
reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_REPOSITION_ITEMS"), 0)
reaper.Undo_EndBlock( "Repositioned Items", 0)