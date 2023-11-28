function Msg(variable)
  dbug = false
  if dbug then reaper.ShowConsoleMsg(tostring(variable).."\n") end
end

local startTime, endTime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
local retval, numMarkers, numRegions = reaper.CountProjectMarkers(0)
local numItems = reaper.CountSelectedMediaItems(0)
if numItems == 0 then Msg("escape") return end
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
if numRegions == nil then  Msg("escape") return end
Msg("hello")
for i = 0, numRegions - 1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if not isrgn then goto continue end
    if pos > startTime and rgnend < endTime then
        Msg("Valid Region")
        distanceStart = nil
        selectedStart = nil
        selidxStart = nil
        --Find Start item for this region
        for j = 0, numItems - 1 do
            Msg("I see items")
            local item =  reaper.GetSelectedMediaItem(0, j)
            local itemStart =  reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            local difference = math.abs(pos - itemStart)
            if difference == 0 then
                distanceStart = difference
                selectedStart = itemStart
                selidxStart = j
                break
            end
            if j == 0 then
                distanceStart = difference
                selectedStart = itemStart
                selidxStart = j
            elseif difference < distanceStart then
                distanceStart = difference
                selectedStart = itemStart
                selidxStart = j
            end
        end
        Msg(selectedStart)
        distanceEnd = nil
        selectedEnd = nil
        selidxEnd = nil
        for j = 0, numItems - 1 do
            local item =  reaper.GetSelectedMediaItem(0, j)
            itemEnd =  reaper.GetMediaItemInfo_Value(item, "D_POSITION") + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
            Msg("-----")
            Msg(itemEnd)
            Msg("-----")
            --reaper.ShowConsoleMsg(itemEnd.."\n")
            difference = math.abs(rgnend - itemEnd)
            if difference == 0 then
                reaper.SetProjectMarker( markrgnindexnumber, isrgn, selectedStart, itemEnd, name )
                Msg("First")
                selectedEnd = itemEnd
                goto continue
            end
            if j == 0 then
                distanceEnd = difference
                selectedEnd = itemEnd
                selidxEnd = j
                Msg("Second")
            elseif difference < distanceEnd then
              Msg("Third")
                distanceEnd = difference
                selectedEnd = itemEnd
                selidxEnd = j
            end
        end
        Msg(selectedEnd)
        reaper.SetProjectMarker( markrgnindexnumber, isrgn, selectedStart, selectedEnd, name )
        goto continue
    end
    ::continue::
end
reaper.Undo_EndBlock("wnlowe Mass Region Resize", 0)
reaper.PreventUIRefresh(-1)
