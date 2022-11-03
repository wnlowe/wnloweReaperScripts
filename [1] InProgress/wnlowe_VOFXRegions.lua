function Msg(variable)
    --reaper.ShowConsoleMsg(tostring (param).."\n")
    return
end

numItems = reaper.CountSelectedMediaItems(0)
allItems = {}
fileName = ""
for i = 0, numItems do
    allItems[i] = reaper.GetSelectedMediaItem(0, i)
end

ret, marks, regs = reaper.CountProjectMarkers(0)
beginning =  reaper.GetMediaItemInfo_Value( allItems[0], "D_POSITION" )
last =  reaper.GetMediaItemInfo_Value( allItems[numItems - 1], "D_POSITION" ) + reaper.GetMediaItemInfo_Value( allItems[numItems - 1], "D_LENGTH" )
number = nil
_number = nil
letter = false

for i = 0, regs + marks do
    ret, isr, regPos, regEnd, regName, MarInx = reaper.EnumProjectMarkers(i)
    if isr and regPos <= beginning and regEnd >= last then
        fileName = tostring(regName)
        number = string.match(fileName, "_(%d+)")
        _number = string.match(fileName, "_(%d+)_")
        if number ~= nil and _number == nil then letter = true end
        break
    end
end

for j = #allItems, 0, -1 do
    local _start =  reaper.GetMediaItemInfo_Value( allItems[j], "D_POSITION" )
    reaper.SetMediaItemInfo_Value( allItems[j], "D_POSITION", _start + j )
end

markRegs = regs + marks
if letter then
    for j = 0, #allItems do
        local _start =  reaper.GetMediaItemInfo_Value( allItems[j], "D_POSITION" )
        local _end =  reaper.GetMediaItemInfo_Value( allItems[j], "D_LENGTH" ) + _start
        reaper.AddProjectMarker( 0, true, _start, _end, string.format("%s_%s", fileName, string.char(64 + j + 1)), markRegs + j )
        reaper.SetProjectMarker(MarInx, true, beginning, _end, regName)
    end
else
    for j = 0, #allItems do
        local _start =  reaper.GetMediaItemInfo_Value( allItems[j], "D_POSITION" )
        local _end =  reaper.GetMediaItemInfo_Value( allItems[j], "D_LENGTH" ) + _start
        reaper.AddProjectMarker( 0, true, _start, _end, string.format("%s_%02d", fileName, j + 1), markRegs + j )
        reaper.SetProjectMarker(MarInx, true, beginning, _end, regName)
    end
end
