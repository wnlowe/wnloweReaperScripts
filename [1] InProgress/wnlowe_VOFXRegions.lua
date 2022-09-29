numItems = reaper.CountSelectedMediaItems(0)
allItems = {}
fileName = ""
for i = 1, numItems do
    allItems[i] = reaper.GetSelectedMediaItem(0, i)
end

ret, marks, regs = reaper.CountProjectMarkers(0)
beginning =  reaper.GetMediaItemInfo_Value( allItems[1], "D_POSITION" )
last =  reaper.GetMediaItemInfo_Value( allItems[#allitems], "D_POSITION" ) + reaper.GetMediaItemInfo_Value( allItems[#allitems], "D_LENGTH" )
for i = 0, regs + marks do
    ret, isr, regPos, regEnd, regName, MarInx = reaper.EnumProjectMarkers(i)
    if isr and regPos <= beginning and regEnd >= last then
        fileName = tostring(regName)
        break
    end
end

markRegs = regs + marks

for j = 1, #allItems do
    --use #allItems to find bounds of region
    local _start =  reaper.GetMediaItemInfo_Value( allItems[j], "D_POSITION" )
    local _end =  reaper.GetMediaItemInfo_Value( allItems[j], "D_LENGTH" ) + _start
    reaper.SetProjectMarker(markRegs + j, true, _start, _end, string.format("%s_%02d", fileName, j))
end