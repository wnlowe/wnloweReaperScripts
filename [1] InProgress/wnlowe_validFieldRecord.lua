debug = false
function Msg(variable)
    if debug then reaper.ShowConsoleMsg(tostring(variable).."\n") end
end
--[[
    SECTION
    Get Marker Names!!!
]]
_resources = reaper.GetResourcePath()

dirname1 = _resources .. '/Scripts/William N. Lowe/wnloweReaperScripts/[3] EditedForPersonalUse/FRTM'
dirname2 = _resources .. '/Scripts/wnloweReaperScripts/[3] EditedForPersonalUse/FRTM'
dirname3 = _resources .. '/Scripts/'
dirname = ""

function exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then
        if code == 13 then
            return true
        end
    end
    return ok
end
function isdir(path)
    return exists(path.."/")
end

function GetCustomPath()
    local continue, customPath = reaper.GetUserInputs("User Path to Scripts", 1, "Where do you have the WNL_FRTakeMarker scripts located within the scripts folder (leave blank if in scripts folder loose)? , Path: extrawidth=150", "")
    if not continue or customPath == "" then return else return customPath end
    -- Msg(customPath)
    -- CycleResponse = {}
    -- for match in (customPath..","):gmatch("(.-),") do table.insert(CycleResponse, match) end
end

if isdir(dirname1) then dirname = dirname1 
elseif isdir(dirname2) then dirname = dirname2
else _extension = GetCustomPath()
    dirname = dirname3.._extension
end

_filenames = {}
idx = 0
markerNames = {}

repeat
    _name = reaper.EnumerateFiles( dirname, idx )
    if _name ~= nil then table.insert( _filenames, _name ) end
    idx = idx + 1
until _name == nil

for a = 1, #_filenames do
    str = _filenames[a]
    for w in str:gmatch("([^_]+)") do 
        if w == "WNL" or w == "FRTakeMarker" then
        elseif string.match(w, ".lua") then table.insert(markerNames, string.sub(w, 1, (string.len(w) - 4))) end
    end
end

--[[
    TODO: 
    [x] Remove the .lua from the names 
    [] ask user to define the names into categories
    [] color markers for you
    [] complete logic of finding best sections
        - 5 minute + section
        [] move finding section with most good to seprate function passing in the array of good
            [] array of good gets trimmed if a warning is found in the good range AND if there is another valid section to exist
            [] once warning is found within best range, remove all good markers from consideration between current start and warning
        [] once range with most good and no/least warnings has been found call it a good section and cut it
            [] can functions be reused and consideration is made to move past the cut section? maybe this is done with finding sections within bad markers
        [] if section before warning is valid that can be used
    [] color the good items
]]

--[[
    SECTION
    Begin action script
]]
function ValidGoodCheck(validGood)
    firstMarkTime = 0
    lastCount = 0
    bestIndex = 0
    --make sure we have at least two
    if #validGood > 1 then
        --start at each relevant good marker and see how many good markers are between it and the end
        for n = 1, #validGood do
            _count = 0
            _time, MarkName, MarkColor = reaper.GetTakeMarker(activeTake, validGood[n])
            firstMarkTime = _time
            for o = n + 1, #validGood do
                _time, MarkName, MarkColor = reaper.GetTakeMarker(activeTake, validGood[o])
                if _time - firstMarkTime < 600 then _count = _count + 1 end
            end
            if _count > lastCount then
                bestIndex = n
                lastCount = _count
            end
        end
    end
    return bestIndex
end

function ReturnWarning(_startTime, _endTime, _time)
    if math.abs(_time - endTime) > 180 and math.abs(_time - _startTime) > 180 then
        
    elseif math.abs(_time - endTime) > 180 then
        return true, _time, endTime
    elseif math.abs(_time - _startTime) > 180 then
        return true, _startTime, _time
    else
        return false, _startTime, _endTime 
    end
end

function ValidWarningCheck(_startTime, _endTime)
    validWarning = {}
    for p = i, #warning do
        _time, MarkName, MarkColor = reaper.GetTakeMarker(activeTake, warning[p])
        if _time > _startTime and _time < endTime then
            table.insert(validWarning[p])
        end
    end
    if #validWarning == 0 then return true, _startTime, _endTime
    elseif #validWarning == 1 then
        _time, MarkName, MarkColor = reaper.GetTakeMarker(activeTake, validWarning[1])
        return ReturnWarning(_startTime, _endTime, _time)
    elseif #validWarning > 1 then
        for q = 1, #validWarning - 1 do
            _timeA, MarkName, MarkColor = reaper.GetTakeMarker(activeTake, validWarning[q])
            _timeB, MarkName, MarkColor = reaper.GetTakeMarker(activeTake, validWarning[q + 1])
            if q == 1 then 
                if math.abs(_timeA - _startTime) > 180 then 

                end
            elseif q == #validWarning - 1 then 
                if math.abs(_timeB - _endTime) > 180 then 

                end 
            elseif math.abs(_time1 - _time2) > 180 then 

            else
                -- make some choice of what to cut and give it a warning color
            end
        end
        
        
    end

end

function OverFiveMinutes(badMarker, _good, _warning, startTime, endTime)
    --[[
        SECTION
        Find Most Good Markers in range
    ]]
    _validGood = {}
    --find all of the good markers that are actually between the two bad markers we are trying to avoid
    if _good then
        for m = i, #good do
            _time, MarkName, MarkColor = reaper.GetTakeMarker(activeTake, good[m])
            if _time > startTime and _time < endTime then 
                table.insert(_validGood,m)
            end
        end
        --[[
            Is there anything before bestTime that would be a valid clip
        ]]
        _bestIndex = ValidGoodCheck(_validGood)
        bestTime, MarkName, MarkColor = reaper.GetTakeMarker(activeTake, _validGood[_bestIndex])
        _startTime = bestTime
        _endTime = endTime
        if _warning then
            _valid, _start, _end = ValidWarningCheck(_startTime, _endTime)
            if _valid then
                _startTime = _start
                _endTime = _end
            else return false end
        end
    end    
end

function OneToFiveMinutes(badMarker, _good, _warning, startTime, endTime)
end

function FindSection(_bad, _good, _warning)
    if _bad and #bad > 1 then
        for k = 1, #bad - 1 do 
            currentTime, MarkName, MarkColor = reaper.GetTakeMarker(activeTake, bad[k])
            nextTime, MarkName, MarkColor = reaper.GetTakeMarker(activeTake, bad[k + 1])
            if nextTime - currentTime > 300 then 
                valid, _begin, _finish = OverFiveMinutes(k, _good, _warning, currentTime, nextTime)
                if valid then CutSection(_begin, _finish) end
            elseif nextTime - currentTime > 120 then 
                valid, _begin, _finish = OneToFiveMinutes(k, _good, _warning, currentTime, nextTime)
                if valid then CutSection(_begin, _finish) end
            end
        end
    end
    
    if #bad == 1 then end
    
end

function hex2rgb(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function HexToInt( hex )
    local hex = hex:gsub("#","")
    local R = tonumber("0x"..hex:sub(1,2))
    local G = tonumber("0x"..hex:sub(3,4))
    local B = tonumber("0x"..hex:sub(5,6))
    return reaper.ColorToNative( R, G, B )
  end

--[[
    SECTION
    UI
]]

package.path = reaper.GetResourcePath() .. '/Scripts/rtk/1/?.lua'
local rtk = require('rtk')
local log = rtk.log
local w = rtk.Window{w=640, h=480}
local main = w:add(rtk.VBox{halign="center", vspacing = 10})
local dropsContainer = main:add(rtk.FlowBox{vspacing=10, hspacing=10})
for z = 1, #markerNames do
    local contain = dropsContainer:add(rtk.VBox{halign = "center"})
    local label = contain:add(rtk.Text{markerNames[z]..":", halign = "center"})
    local sevarity = contain:add(rtk.OptionMenu{
        menu={
            {'Good', id='good', color = '#00FFFF'},
            {'Bad', id = 'bad', color='#FF0000'},
            {'Warning', id = 'warning', color='#FFFF00'},
            {'Note', id='purple', color='#7f00ff'},
        }, 
    })

    sevarity.onchange = function(self, item)
        Msg(self)
        self:attr('color', item.color)
    end

    sevarity:attr('selected', 'purple')

end


local b = rtk.Button{label='Hello world', iconpos='right'}
GlobalColors = {}
b.onclick = function()
   -- Toggles between a circle and rectangular button when clicked.
   for y = 1, #markerNames do
    cont = dropsContainer:get_child(y)
    val = cont:get_child(2)
    GlobalColors[markerNames[y]] = {HexToInt(val.color)}
   end
   w:close()
   Main()
   reaper.UpdateArrange()
end

main:add(b)

w:open()

--[[
    SECTION
    Main Loop
]]
function Main()
    numMediaItem = reaper.CountSelectedMediaItems(0)
    if numMediaItem == 0 then return end


    for i = 0, numMediaItem -1 do
        selMediaItem = reaper.GetSelectedMediaItem(0, i)
        activeTake =  reaper.GetActiveTake( selMediaItem )
        numMark = reaper.GetNumTakeMarkers( activeTake )
        good = {}
        warning = {}
        bad = {}
        -- checkGood = {[r] = 0, [g] = 255, [b] = 255}
        -- checkWarning = {[r] = 255, [g] = 255, [b] = 255}
        -- checkBad = {[r] = 255, [g] = 0, [b] = 0}
        for j = 0, numMark do
            MarkTime, MarkName, MarkColor = reaper.GetTakeMarker(activeTake, j)
            if GlobalColors[MarkName] ~= nil then
                color = GlobalColors[MarkName][1]
                reaper.SetTakeMarker( activeTake, j, MarkName, MarkTime, color|0x1000000)
            end
            
            --[[for x = 1, #markerNames do
                if MarkName == markerNames[x] then
                    Msg(markerNames[x])
                    cn = markerNames[x]
                    gc = GlobalColors[cn]
                    color = gc[1]
                    r, s, t = reaper.ColorFromNative(color)
                    Msg(r)
                    Msg(s)
                    Msg(t)
                    reaper.SetTakeMarker( activeTake, j, MarkName, MarkTime, color|0x1000000) 
                end
            end]]
            -- MarkTime, MarkName, MarkColor = reaper.GetTakeMarker(activeTake, j)
            -- Msg("-------")
            -- colR, colG, colB = reaper.ColorFromNative( MarkColor )
            -- Msg(colR)
            -- Msg(colG)
            -- Msg(colB)
            -- Msg("-------")
            -- if colR == 0 then table.insert(good, j)
            -- elseif colG == 0 then table.insert(bad, j)
            -- else table.insert(warning, j)
            -- end
        end
        --[[if #good > 0 then isGood = true end
        if #warning > 0 then isWarnings = true end
        if #bad > 0 then isBad = true end]]
        -- FindSection(isBad, isGood, isWarnings)
        
    end
end