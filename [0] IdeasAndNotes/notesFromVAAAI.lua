
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