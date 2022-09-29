numItems = reaper.CountSelectedMediaItems(0)
allItems = {}

for i = 1, numItems do
    allItems[i] = reaper.GetSelectedMediaItem(0, i)
end

ret, marks, regs = reaper.CountProjectMarkers(0)
beginning =  reaper.GetMediaItemInfo_Value( allItems[1], "D_POSITION" )
last =  reaper.GetMediaItemInfo_Value( allItems[#allitems], "D_POSITION" ) + reaper.GetMediaItemInfo_Value( allItems[#allitems], "D_LENGTH" )
for i = 0, regs + marks do
    ret, isr, regPos, regEnd, regName, MarInx = reaper.EnumProjectMarkers(i)
    if isr and regPos <= beginning and regEnd >= last then
        reaper.SetProjectMarker(MarInx, true, beginning, last, regName)
    end
end