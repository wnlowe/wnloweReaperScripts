
--Msg function from marc carlton
function Msg(variable)
    reaper.ShowConsoleMsg(tostring(variable).."\n")
end

function scale(oldValue, oldMin, oldMax, newMin, newMax)
    local oldRange = oldMax - oldMin
    local newRange = newMax - newMin
    return (((oldValue - oldMin) * newRange) / oldRange) + newMin
end
------------------------------------------------------------
-- Mod from SPK77
-- http://forum.cockos.com/showpost.php?p=1608719&postcount=6
--Trak_Vol_dB = 20*math.log(val, 10) end
--Trak Vol val = 10^(dB_val/20) end
------------------------------------------------------------


-------------------------------------------------------------
-- item Vol conversion    https://forum.cockos.com/showthread.php?p=2200278#post2200278



-----------------------------------------------------------
local LN10_OVER_TWENTY = 0.11512925464970228420089957273422
function DB2VAL(x) return math.exp(x*LN10_OVER_TWENTY) end

function VAL2DB(x)
  if x < 0.0000000298023223876953125 then
    return -150
  else
    return math.max(-150, math.log(x)* 8.6858896380650365530225783783321); 
  end
end

function dbtoamp(decibels)
    local amps = 10^(decibels / 20)
    Msg(amps)
    return amps
end

function dBToAutomation(x)
    if x > -23.1 then return 714.7520864 + 21.62084026*x + 0.1907747361 * x^(2)
    else return 702.833988 * 1.035972147 ^ (x) end
end

function SetVolumePoints(mi, c, db)
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEENV1"), 0) --get take
    local env = reaper.GetTakeEnvelopeByName(reaper.GetActiveTake(mi), "Volume") --get volume envelope
    Mode = reaper.GetEnvelopeScalingMode(env)
    local ct = c/2 -- cycle length / 2 to get time between points
    --local value = scale(dbtoamp(db), 0, dbtoamp(12), 0, 1000)
    local value = dBToAutomation(tonumber(db))
    Msg("---")
    Msg(value)
    Msg("---")
    for k=0, NumCycles*2+1 do
        if k%2 == 0 then vol = value else vol = 716.21785031263 end
        reaper.InsertEnvelopePoint(env, c*k, vol, 0, 0, false)
        --reaper.SetEnvelopePointEx(env, -1, k, ct, vol, shapeIn, tensionIn, selectedIn, true)
        --Msg(k)
    end

    --reaper.InsertEnvelopePointEx(env, -1, 0, 1, 0, 0, false, false)
    --reaper.Envelope_SortPoints(env)
    Msg("End")
end
--Find all items
SelItemCount = reaper.CountSelectedMediaItems(0)
--Find lengths of items
LongestKey = nil
Items = {}
for i=1,SelItemCount do
    local sel = reaper.GetSelectedMediaItem(0, i-1)
    Msg("Sel")
    Msg(sel)
    Items[sel] = reaper.GetMediaItemInfo_Value(sel, "D_LENGTH")
    Msg(reaper.GetTakeName(reaper.GetActiveTake(sel)))
    Msg("Length")
    Msg(reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, 0), "D_LENGTH"))
    Msg("Items")
    Msg(Items[sel])
    if not LongestKey then LongestKey = sel else 
        if Items[sel] > Items[LongestKey] then LongestKey = sel
        end
    end
end

Msg(LongestKey)
Msg(Items[LongestKey])
--Get User Input and parse it
local continue, Cycles = reaper.GetUserInputs("Volume Cycle Count", 2, "How Many Volume Cycles? , Max Volume in dBs: extrawidth=150", "")
if not continue or Cycles == "" then return end
Msg(Cycles)
CycleResponse = {}
for match in (Cycles..","):gmatch("(.-),") do table.insert(CycleResponse, match) end
for i=1, #CycleResponse do if i == 1 then NumCycles = CycleResponse[i] elseif i==2 then MaxVol = CycleResponse[i] end end
Msg(NumCycles)
Msg(MaxVol)
CycleLength = Items[LongestKey] / NumCycles
--Do processing on the longest item
SetVolumePoints(LongestKey, CycleLength, MaxVol)



--[[
LongestTake = reaper.GetActiveTake(LongestKey)
LongestEnvelope = reaper.GetTakeEnvelopeByName(LongestTake, "Volume")
]]

--MediaTrack = reaper.GetMediaItemInfo_Value(LongestKey, "P_Track")
--TrackEnvelope reaper.GetTakeEnvelopeByName(MediaItem_Take take, string envname)
--boolean reaper.InsertEnvelopePoint(TrackEnvelope envelope, number time, number value, integer shape, number tension, boolean selected, optional boolean noSortIn)
-- reaper.GetTrackEnvelopeByName( track, envname )



--[[
SortedLength = {} --blank for sort based on gammon.com.au/scripts/doc.php?lua=table.sort
--table.foreach(Items, function(k,v) table.insert(SortedLength, v) end)
for k,v in pairs(Items) do
    table.insert(SortedLength, v)
end
table.sort(SortedLength)
]]

    --[[boolean reaper.SetEnvelopePointEx(TrackEnvelope envelope, integer autoitem_idx, 
        integer ptidx, optional number timeIn, optional number valueIn, optional integer shapeIn, 
        optional number tensionIn, optional boolean selectedIn, optional boolean noSortIn)]]
    --[[boolean reaper.SetEnvelopePoint(TrackEnvelope envelope, integer ptidx, optional number timeIn, 
        optional number valueIn, optional integer shapeIn, optional number tensionIn, 
        optional boolean selectedIn, optional boolean noSortIn)]]

        --[[boolean reaper.InsertEnvelopePointEx(TrackEnvelope envelope, integer autoitem_idx, number time, number value, 
            integer shape, number tension, boolean selected, optional boolean noSortIn)
        Insert an envelope point. If setting multiple points at once, set noSort=true, and call Envelope_SortPoints when done.
        autoitem_idx=-1 for the underlying envelope, 0 for the first automation item on the envelope, etc.
        For automation items, pass autoitem_idx|0x10000000 to base ptidx on the number of points in one full loop iteration,
        even if the automation item is trimmed so that not all points are visible.
        Otherwise, ptidx will be based on the number of visible points in the automation item, including all loop iterations.]]
--[[

        StartTime, EndTime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
        duration = EndTime - StartTime
        
        local envelope = reaper.GetSelectedEnvelope(0)
        --boolean reaper.InsertEnvelopePoint(TrackEnvelope envelope, number time, number value, integer shape, number tension, boolean selected, optional boolean noSortIn)
        --start point
        reaper.InsertEnvelopePoint(envelope, StartTime, 100, 0, 1, true, false)
        --Attack Point
        reaper.InsertEnvelopePoint(envelope, StartTime + (duration*0.25), 200, 0, 0.5, true, false)
        --Decay
        reaper.InsertEnvelopePoint(envelope, StartTime + (duration*0.5), 100, 0, 0.5, true, false)
        --Sustain
        reaper.InsertEnvelopePoint(envelope, StartTime + (duration*0.75), 100, 0, 0, true, false)
        --Release
        reaper.InsertEnvelopePoint(envelope, EndTime, 100, 0, 0, true, false)
]]