function Msg(variable)
    reaper.ShowConsoleMsg(tostring (param).."\n")
end

function GetRenderTrack(region)
    local ret, isr, regPos, regEnd, regName, MarInx = reaper.EnumProjectMarkers(region)
    return  reaper.EnumRegionRenderMatrix( 0, MarInx, 0 )
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
relReg = {}
compDif = nil
compSel = nil

for i = 0, regs + marks do
    ret, isr, regPos, regEnd, regName, MarInx = reaper.EnumProjectMarkers(i)
    if isr and regPos < beginning then
        if compDif == nil then 
            compDif = math.abs(regPos - beginning)
            compSel = i
        else
            if compDif > math.abs(regPos - beginning) then
                compDif = math.abs(regPos - beginning)
                compSel = i
            end
        end
    end
end

ret, isr, regPos, regEnd, regName, MarInx = reaper.EnumProjectMarkers(compSel)
NewRegion = reaper.AddProjectMarker(0, true, beginning, last, string.format("%s_%s", tostring(regName), "ALT"), 1)
RenderTrack = GetRenderTrack(compSel)
if RenderTrack ~= nil then reaper.SetRegionRenderMatrix( 0, NewRegion, RenderTrack, 1 ) end