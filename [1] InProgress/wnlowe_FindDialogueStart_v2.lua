function Msg (param)
    reaper.ShowConsoleMsg(tostring (param).."\n")
end

item = reaper.GetSelectedMediaItem(0, 0)
if not item then return end

itemPos = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
itemLen = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH' ) 
boundaryStart = itemPos
boundaryEnd = itemPos + itemLen

windowSize = 0.2
take = reaper.GetActiveTake(item)
accessor = reaper.CreateTakeAudioAccessor( take ) 
samplerate = 48000--tonumber(reaper.format_timestr_pos( 1-reaper.GetProjectTimeOffset( 0,false ), '', 4 )) -- get sample rate obey project start offset
bufferSize = math.ceil(0.2 * samplerate)
numChannels = 1
sampleReadBuffer = reaper.new_array(bufferSize);

collectedSamples = {}
readPos = 0
writePos = 0
samplePos = 0

threshold = reaper.DB2SLIDER(-40.0)
topThreshold = reaper.DB2SLIDER(-39.0)

function fillBuffer()
    for pos = boundaryStart, boundaryEnd, windowSize do
        reaper.GetAudioAccessorSamples( accessor, samplerate, numChannels, readPos, bufferSize, sampleReadBuffer)
        for i = 1, bufferSize do
            collectedSamples[writePos+i] = math.abs( sampleReadBuffer[i] )
        end 
        sampleReadBuffer.clear()
        writePos = writePos + bufferSize
        readPos = readPos + windowSize
    end
    reaper.DestroyAudioAccessor( accessor )
end

function processSamples()
    local _offset = 0
    local _readpos = 1
    Msg(_readpos)
    Msg(#collectedSamples)
    if 1 >= #collectedSamples then return 0 end
    
    for i = 1, #collectedSamples do

        --local mag2Db = 20 * math.log(collectedSamples[i], 10)      -- value at sample position
        _offset = i                                      -- sample position in collectedSamples
        
        if collectedSamples[i] > threshold and collectedSamples[i] < topThreshold then Msg("Success: "..i)
            Msg(20 * math.log(collectedSamples[i], 10)) break
        end
    end
    
    newTop = samplePos+itemPos
    samplePos = _offset / samplerate
    reaper.ApplyNudge(0, 1, 6, 1, samplePos+itemPos, false, 0)
    --reaper.Main_OnCommand(40157, 0) -- add marker
    reaper.Main_OnCommand(41305, 0) -- cut edge    
    
        
    --process backwards
    for i = #collectedSamples, 1, -1 do
        --local mag2Db = 20 * math.log(collectedSamples[i], 10)
        _offset = i
        if collectedSamples[i] > threshold and collectedSamples[i] < topThreshold then Msg("Success: "..i)
            Msg(20 * math.log(collectedSamples[i], 10)) break
        end
    end

    newEnd = samplePos+itemPos
    samplePos = _offset / samplerate
    reaper.ApplyNudge(0, 1, 6, 1, samplePos+itemPos, false, 0)
    --reaper.Main_OnCommand(40157, 0) -- add marker
    reaper.Main_OnCommand(41311, 0) -- cut edge
    return
end

fillBuffer()
Msg(#collectedSamples)
processSamples()