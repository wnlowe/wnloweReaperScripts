function Msg(variable)
    --reaper.ShowConsoleMsg(tostring (variable).."\n")
    return
end

StartTime, EndTime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
ret, marks, regs = reaper.CountProjectMarkers(0)

validRegions = {}
validMarkers = {}

for i = 0, regs + marks do
    ret, isr, regPos, regEnd, regName, MarInx = reaper.EnumProjectMarkers(i)
    if regPos > StartTime and regPos < EndTime then
        if (isr) then
            table.insert(validRegions, i)
        else
            table.insert(validMarkers, i)
        end
    end
end

markerOrder = {}

for i = 1, #validRegions do
    bestTime = 0
    bestMarker = 1
    ret, isr, regPos, regEnd, regName, regInx = reaper.EnumProjectMarkers(validRegions[i])
    for j = 1, #validMarkers do
        ret, isr, marPos, marEnd, marName, marInx = reaper.EnumProjectMarkers(validMarkers[j])
        if j == 1 then bestTime = math.abs(regPos - marPos)
        else
            newTime = math.abs(regPos - marPos)
            if newTime < bestTime then
                bestTime = newTime
                bestMarker = j
            end
        end
    end
    ret, isr, marPos, marEnd, marName, marInx = reaper.EnumProjectMarkers(validMarkers[bestMarker])
    reaper.SetProjectMarker(regInx, true, regPos, regEnd, marName)
end

