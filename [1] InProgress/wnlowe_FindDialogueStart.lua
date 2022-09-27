
pSR = 48000 -- reaper.GetSetProjectInfo(0,"PROJECT_SRATE",0,false)
channels = 1 --reaper.GetMediaItemTakeInfo_Value( activeTake, parmname )
buferLength = 1024

--Msg function from marc carlton
function Msg(variable)
    reaper.ShowConsoleMsg(tostring(variable).."\n")
end

reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELITEMSUNDEDCURSELTX"), 0)
activeTake = reaper.GetActiveTake(reaper.GetSelectedMediaItem(0, 0))
Accessor = reaper.CreateTakeAudioAccessor(activeTake)
sTime = reaper.GetAudioAccessorStartTime(Accessor)
samBuf = reaper.new_array(channels*buferLength)
takeEnv = reaper.GetTakeEnvelopeByName(activeTake, "Volume") --get volume envelope
Mode = 1
--get length of media item
itemLength =  reaper.GetMediaItemInfo_Value( reaper.GetSelectedMediaItem(0, 0), "D_LENGTH" ) * pSR--reaper.GetMediaItemTakeInfo_Value(activeTake, "D_LENGTH") * pSR
Msg("Hello")
Msg(sTime)
Msg(itemLength)
Msg(pSR)
Msg((itemLength - buferLength + 1))
buf = reaper.new_array(channels*buferLength)

errorOut = 0
while sTime < (itemLength - buferLength + 1) and errorOut < 3 do
    Msg("hi")
    reaper.GetAudioAccessorSamples(Accessor, pSR, channels, sTime, buferLength, buf)
    for i = 1, #buf, 1 do
        if buf[i] > 0 then
            Msg(reaper.ScaleToEnvelopeMode(Mode, buf[i]))
        end
    end
    sTime = sTime + buferLength
    errorOut = errorOut + 1
end




--[[
reaper.CreateTakeAudioAccessor( take )
reaper.DestroyAudioAccessor( accessor )
reaper.GetAudioAccessorStartTime( accessor )
reaper.GetAudioAccessorEndTime( accessor )
reaper.GetAudioAccessorSamples( accessor, samplerate, numchannels, starttime_sec, numsamplesperchannel, samplebuffer )]]