
pSR = 48000 -- reaper.GetSetProjectInfo(0,"PROJECT_SRATE",0,false)
channels = 1 --reaper.GetMediaItemTakeInfo_Value( activeTake, parmname )
buferLength = 1024
fadeInAmountMs = 20
fadeOutAmountMs = 80

--Msg function from marc carlton
function Msg(variable)
    reaper.ShowConsoleMsg(tostring(variable).."\n")
end

function pullDataForward()
    for pos = sTime, itemLength, 1 do
        buf = reaper.new_array(channels*buferLength)
        reaper.GetAudioAccessorSamples(Accessor, pSR, channels, pos, buferLength, buf)
        buf.table()
        for i = 1, #buf, 1 do
            output = reaper.ScaleToEnvelopeMode(Mode, buf[i])
            if output > 200 then return (i + id) end
            data[i + id] = buf[i]
        end
        id = id + buferLength
        buf.clear()
    end
end

function findHead()
    Accessor = reaper.CreateTakeAudioAccessor(activeTake)
    sTime = reaper.GetAudioAccessorStartTime(Accessor)
    samBuf = reaper.new_array(channels*buferLength)
    takeEnv = reaper.GetTakeEnvelopeByName(activeTake, "Volume") --get volume envelope
    Mode = 1
    --get length of media item
    itemLength =  reaper.GetMediaItemInfo_Value( item, "D_LENGTH" ) * pSR--reaper.GetMediaItemTakeInfo_Value(activeTake, "D_LENGTH") * pSR

    data = {}
    id = 0

    Slocation = pullDataForward() / pSR
    Sdestination = reaper.GetMediaItemInfo_Value(item, "D_POSITION") + Slocation
    reaper.ApplyNudge(0, 1, 6, 1, Sdestination, false, 0)
    reaper.DestroyAudioAccessor(Accessor)
end

function pullDataBackward()
    itemStartTime = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    for pos = itemLength, sTime, -1 do
        Msg("hi")
        buf = reaper.new_array(channels*buferLength)
        reaper.GetAudioAccessorSamples(Accessor, pSR, channels, pos, buferLength, buf)
        buf.table()
        for i = #buf, 1, -1 do
            output = reaper.ScaleToEnvelopeMode(Mode, buf[i])
            if output > 200 then return (itemLength - (i + id)) end
            data[i + id] = buf[i]
        end
        id = id + buferLength
        buf.clear()
    end
end

function findTail()
    Accessor = reaper.CreateTakeAudioAccessor(activeTake)
    sTime = reaper.GetAudioAccessorStartTime(Accessor)
    samBuf = reaper.new_array(channels*buferLength)
    takeEnv = reaper.GetTakeEnvelopeByName(activeTake, "Volume") --get volume envelope
    Mode = 1
    --get length of media item
    itemLength =  reaper.GetMediaItemInfo_Value( item, "D_LENGTH" ) * pSR --reaper.GetMediaItemTakeInfo_Value(activeTake, "D_LENGTH") * pSR

    data = {}
    id = 0

    Elocation = pullDataBackward() / pSR
    Edestination = reaper.GetMediaItemInfo_Value(item, "D_POSITION") + Elocation
    reaper.ApplyNudge(0, 1, 6, 1, Edestination, false, 0)
    reaper.DestroyAudioAccessor(Accessor)
end

reaper.Undo_BeginBlock()
reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELITEMSUNDEDCURSELTX"), 0)
item = reaper.GetSelectedMediaItem(0, 0)
activeTake = reaper.GetActiveTake(item)
itemStartTime = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
head = 0
tail = 0
ret, marks, regs = reaper.CountProjectMarkers(0)

findHead()
itemLength =  reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
--moves edit cursor left to make head cut
if (Sdestination - (fadeInAmountMs / 2 / 1000)) < itemStartTime then head = (Slocation * 1000)
else head = fadeInAmountMs end
reaper.ApplyNudge(0, 0, 6, 0, head / 2, true, 0)
reaper.Main_OnCommand(41305, 0)
reaper.ApplyNudge(0, 0, 6, 0, head, false, 0)
reaper.Main_OnCommand(40509, 0)
reaper.Main_OnCommand(41515, 0)
-- head complete! 
findTail()
itemLength =  reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
if (Edestination + (fadeOutAmountMs / 4 / 1000)) > (itemStartTime + itemLength) then tail = ((itemLength - Elocation) * 1000)
else tail = fadeOutAmountMs end
reaper.ApplyNudge(0, 0, 6, 0, tail / 4, false, 0)
reaper.Main_OnCommand(41311, 0)
reaper.ApplyNudge(0, 0, 6, 0, tail, true, 0)
reaper.Main_OnCommand(40510, 0)
reaper.Main_OnCommand(41526, 0)
--Tail complete! 
itemStartTime = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
itemLength =  reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
for i = 0, regs + marks do
    ret, isr, regPos, regEnd, regName, MarInx = reaper.EnumProjectMarkers(i)
    if isr and regPos < itemStartTime and regEnd > (itemStartTime + itemLength) then
        reaper.SetProjectMarker(MarInx, true, itemStartTime, itemStartTime + itemLength, regName)
    end
end
reaper.Undo_EndBlock( "Heads and Tails on item", 0)

--[[
reaper.CreateTakeAudioAccessor( take )
reaper.DestroyAudioAccessor( accessor )
reaper.GetAudioAccessorStartTime( accessor )
reaper.GetAudioAccessorEndTime( accessor )
reaper.GetAudioAccessorSamples( accessor, samplerate, numchannels, starttime_sec, numsamplesperchannel, samplebuffer )
while sTime < (itemLength - buferLength + 1) and errorOut < 3 do
ret, marks, regs = reaper.CountProjectMarkers(0)

AddRegions = {}
for i = 0, regs + marks do
    ret, isr, regPos, regEnd, regName, MarInx = reaper.EnumProjectMarkers(i)
    if isr and regPos > StartTime and regPos < EndTime then
        table.insert(AddRegions, MarInx)
    end
end

]]