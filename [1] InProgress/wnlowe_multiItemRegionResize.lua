numItems = reaper.CountSelectedMediaItems(0)
allItems = {}

for i = 0, numItems do
    allItems[i] = reaper.GetSelectedMediaItem(0, i)
end

ret, marks, regs = reaper.CountProjectMarkers(0)
beginning =  reaper.GetMediaItemInfo_Value( allItems[0], "D_POSITION" )
last =  reaper.GetMediaItemInfo_Value( allItems[numItems - 1], "D_POSITION" ) + reaper.GetMediaItemInfo_Value( allItems[numItems -1], "D_LENGTH" )
relReg = {}
for i = 0, (regs + marks) do
    ret, isr, regPos, regEnd, regName, MarInx = reaper.EnumProjectMarkers(i)
    selection = 0
    if isr and regPos <= beginning and regEnd >= last then
        selection = selection + 1
        --table.insert(relReg, i)    --reaper.SetProjectMarker(MarInx, true, beginning, last, regName)
    end
    if isr and regPos >=beginning and regPos <= last then
        selection = selection + 1
    end
    if isr and regEnd >= beginning and regEnd <= last then
        selection = selection + 1
    end
    if selection > 0 then table.insert(relReg, i) end
end
if #relReg > 1 then
    ret, isr, regPos, regEnd, regName, MarInx = reaper.EnumProjectMarkers(relReg[1])
    compStart = math.abs(regPos - beginning)
    compEnd = math.abs (regEnd - last)
    compTotal = compStart + compEnd
    choice = 1
    for i = 2, #relReg do
        ret, isr, regPos, regEnd, regName, MarInx = reaper.EnumProjectMarkers(relReg[i])
        curStart = math.abs(regPos - beginning)
        curEnd = math.abs (regEnd - last)
        curTotal = curStart + curEnd
        if curTotal < compTotal then 
            choice = i
            compTotal = curTotal
            compStart = curStart
            compEnd = curEnd
        end
    end
    ret, isr, regPos, regEnd, regName, MarInx = reaper.EnumProjectMarkers(relReg[choice])
    reaper.SetProjectMarker(MarInx, true, beginning, last, regName)
else
    ret, isr, regPos, regEnd, regName, MarInx = reaper.EnumProjectMarkers(relReg[1])
    reaper.SetProjectMarker(MarInx, true, beginning, last, regName)
end
