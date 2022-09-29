function Msg (param)
    reaper.ShowConsoleMsg(tostring (param).."\n")
end

item = reaper.GetSelectedMediaItem(0, 0)
if not item then return end

-------- Get Item Length and Position
local item_pos = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
local item_len = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH' ) 
local boundary_start = item_pos
local boundary_end = item_pos + item_len

------INIT Accesor and Variables

local window_size = 0.2
local take = reaper.GetActiveTake(item)
local accessor = reaper.CreateTakeAudioAccessor( take ) 
local samplerate = tonumber(reaper.format_timestr_pos( 1-reaper.GetProjectTimeOffset( 0,false ), '', 4 )) -- get sample rate obey project start offset
local bufferSize = math.ceil(0.2 * samplerate)
local numChannels = 1
local sampleReadBuffer = reaper.new_array(bufferSize);

local collected_samples = {}
local read_pos = 0
local write_pos = 0

local threshold = -40.0
local topThreshold = -39.0
local thresholdScaled = reaper.DB2SLIDER(threshold)  --> already in mode 1 scale

-------- iterate through buffer to get all the samples

for pos = boundary_start, boundary_end, window_size do
    reaper.GetAudioAccessorSamples( accessor, samplerate, numChannels, read_pos, bufferSize, sampleReadBuffer)
    for i = 1, bufferSize do
        collected_samples[write_pos+i] = math.abs( sampleReadBuffer[i] )
    end 
    sampleReadBuffer.clear()
    write_pos = write_pos + bufferSize
    read_pos = read_pos + window_size
end

--Msg("complete")

reaper.DestroyAudioAccessor( accessor )

local samplePos = 0

--local newTop = 0
--local newEnd = 0

function processSamples(readPos, table, jumptToEnd)
    local offset = 0
    if readPos >= #table then return 0 end
    
    for i = readPos, #table do

        local mag2Db = 20 * math.log(table[i], 10)      -- value at sample position
        offset = i                                      -- sample position in table
        
        if mag2Db > threshold and mag2Db < topThreshold then Msg("Success: "..i)
            Msg(mag2Db) break
        end
    end
    
    newTop = samplePos+item_pos
    samplePos = offset / samplerate
    reaper.ApplyNudge(0, 1, 6, 1, samplePos+item_pos, false, 0)
    --reaper.Main_OnCommand(40157, 0) -- add marker
    reaper.Main_OnCommand(41305, 0) -- cut edge    
    
    if jumptToEnd == true then 
        
        --process backwards
        for i = #table, 1, -1 do
            local mag2Db = 20 * math.log(table[i], 10)
            offset = i
            if mag2Db > threshold and mag2Db < topThreshold then Msg("Success: "..i)
                Msg(mag2Db) break
            end
        end

        newEnd = samplePos+item_pos
        samplePos = offset / samplerate
        reaper.ApplyNudge(0, 1, 6, 1, samplePos+item_pos, false, 0)
        --reaper.Main_OnCommand(40157, 0) -- add marker
        reaper.Main_OnCommand(41311, 0) -- cut edge
        return
    end
end

processSamples (1, collected_samples, true)
--reaper.BR_SetItemEdges( item, newTop, newEnd )