
pSR = 48000 -- reaper.GetSetProjectInfo(0,"PROJECT_SRATE",0,false)
channels = 1 --reaper.GetMediaItemTakeInfo_Value( activeTake, parmname )
buferLength = 1024
fadeInAmountMs = 60
fadeOutAmountMs = 90

--Msg function from marc carlton
function Msg(variable)
    reaper.ShowConsoleMsg(tostring(variable).."\n")
end

function pullDataForward()
    for pos = sTime, itemLength, 1 do
        Msg("hi")
        buf = reaper.new_array(channels*buferLength)
        reaper.GetAudioAccessorSamples(Accessor, pSR, channels, pos, buferLength, buf)
        for i = 1, #buf, 1 do
            output = reaper.ScaleToEnvelopeMode(Mode, buf[i])
            --[[if output > 0.2 then
                Msg(output)
            end]]
            if output > 200 then return (i + id) end
            data[i + id] = buf[i]
        end
        --sTime = sTime + buferLength
        id = id + buferLength
        buf.clear()
        --errorOut = errorOut + 1
        --if errorOut == 3 then break end
    end
end

reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELITEMSUNDEDCURSELTX"), 0)
item = reaper.GetSelectedMediaItem(0, 0)
activeTake = reaper.GetActiveTake(item)
Accessor = reaper.CreateTakeAudioAccessor(activeTake)
sTime = reaper.GetAudioAccessorStartTime(Accessor)
samBuf = reaper.new_array(channels*buferLength)
takeEnv = reaper.GetTakeEnvelopeByName(activeTake, "Volume") --get volume envelope
Mode = 1
--get length of media item
itemLength =  reaper.GetMediaItemInfo_Value( item, "D_LENGTH" ) * pSR--reaper.GetMediaItemTakeInfo_Value(activeTake, "D_LENGTH") * pSR
Msg("Hello")
Msg(sTime)
Msg(itemLength)
Msg(pSR)
Msg((itemLength - buferLength + 1))

data = {}
id = 0

--errorOut = 0
location = pullData() / pSR
destination = reaper.GetMediaItemInfo_Value(item, "D_POSITION") + location
reaper.ApplyNudge(0, 1, 6, 1, destination, false, 0)



--[[
reaper.CreateTakeAudioAccessor( take )
reaper.DestroyAudioAccessor( accessor )
reaper.GetAudioAccessorStartTime( accessor )
reaper.GetAudioAccessorEndTime( accessor )
reaper.GetAudioAccessorSamples( accessor, samplerate, numchannels, starttime_sec, numsamplesperchannel, samplebuffer )
while sTime < (itemLength - buferLength + 1) and errorOut < 3 do
]]