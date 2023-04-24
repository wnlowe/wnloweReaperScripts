---------------------------------------------
---------------------------------------------
--HELPER FUNCTIONS
---------------------------------------------
---------------------------------------------

function Msg(variable)
    dbug = true
    if dbug then reaper.ShowConsoleMsg(tostring (variable).."\n") end
end

--CSV Helper function from https://nocurve.com/2014/03/05/simple-csv-read-and-write-using-lua/
function string:split(sSeparator, nMax, bRegexp)
    if sSeparator == '' then sSeparator = ',' end
    if nMax and nMax < 1 then nMax = nil end
    local aRecord = {}
    if self:len() > 0 then
        local bPlain = not bRegexp
        nMax = nMax or -1
        local nField, nStart = 1, 1
        local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
        while nFirst and nMax ~= 0 do
            aRecord[nField] = self:sub(nStart, nFirst-1)
            nField = nField+1
            nStart = nLast+1
            nFirst,nLast = self:find(sSeparator, nStart, bPlain)
            nMax = nMax-1
        end
        aRecord[nField] = self:sub(nStart)
    end
    return aRecord
end

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
---------------------------------------------
---------------------------------------------
--ONE TIME CSV
---------------------------------------------
---------------------------------------------
function readModes()
    local data = {}
    local mode_idx = 0
    local submode_idx = 0
    local str = ''
    while true do
        local mode_ret, mode_str = reaper.EnumPitchShiftModes(mode_idx)
        if not mode_ret then break end
        if mode_str and mode_str:len() > 0 then
            local continue = true
            while continue do
                local submode_str = reaper.EnumPitchShiftSubModes(mode_idx, submode_idx)
                if submode_str and submode_str:len() > 0 then
                    local idx = mode_idx<<16|submode_idx
                    str = str .. idx .. ',' .. mode_idx .. ',' .. mode_str .. ',' .. submode_idx .. ',' .. submode_str
                    -- local _, count = string.gsub(str, ",", "")
                    -- for z in string.gsub(str, ",") do
                    --     count = count + 1
                    -- end
                    str = str ..  '\n' --',' .. count ..
                    submode_idx = submode_idx + 1
                else
                    submode_idx = 0
                    continue = false
                end
            end
        end
        mode_idx = mode_idx + 1 
    end
    for line in string.gmatch(str,'[^\r\n]+') do
        fields = line:split(',')
        local count = #fields - 4
        table.insert(fields, count)
        table.insert(data, fields)
    end
    return data
end

function writeData(csv)
    fileInput = {}
    fileInput = readModes()
    local file = assert(io.open(csv, "w"))
    file:write("Version,"..version..'\n')
    for i = 1, #fileInput do
        for j = 1, #fileInput[i] do
            if j == 3 then
                -- fileInput[i][j] = fileInput[i][j]:gsub('Ã©', 'E')
                if string.find(fileInput[i][j], "lastique") then
                    local arr = {}
                    for word in fileInput[i][j]:gmatch("%S+") do
                        table.insert( arr, word)
                    end
                    arr[1] = 'Elastique'
                    local replace = ''
                    for a = 1, #arr do
                        if a > 1 then replace = replace .. ' ' end
                        replace = replace .. arr[a]
                    end
                    fileInput[i][j] = replace
                end
            end
            if j > 1 then file:write(',') end
            if fileInput[i][j] ~= nil then
                file:write(fileInput[i][j])
            end
        end
        file:write('\n')
    end
    file:close()
end

midExtension = reaper.GetResourcePath() .. '/Scripts/William N. Lowe/wnloweReaperScripts/'
extAlt = reaper.GetResourcePath() .. '/Scripts/wnloweReaperScripts/'
if not isdir(midExtension) then
    if isdir(extAlt) then
        midExtension = extAlt
    else midExtension = reaper.GetResourcePath() .. '/Scripts/' end
end
csvName =  midExtension ..'PitchAlgoOptions.csv'
version =  reaper.GetAppVersion()

if not exists(csvName) then
    Msg("Not Exist")
    writeData(csvName)
else
    fileOutput = {}
    local file = assert(io.open(csvName, "r"))
    for line in file:lines() do
        fields = line:split(',')
        table.insert(fileOutput, fields)
    end
    file:close()
    if fileOutput[1][2] ~= version then
        file = assert(io.open(csvName, "w"))
        for i = 1, #fileOutput do
            for j = 1, #fileOutput[i] do
                if j > 1 then file:write(',') end
                file:write('')
            end
            file:write('\n')
        end
        file:close()
        Msg("Edit")
        writeData(csvName)
    end
end
----------------------------------------------------------------
----------------------------------------------------------------
--FILE HAS BEEN WRITTEN
----------------------------------------------------------------
----------------------------------------------------------------
function findData()
    local fileData = {}
    if fileOutput == nil then
        if fileInput == nil then
            file = assert(io.open(csvName, "r"))
            for line in file:lines() do
                fields = line:split(',')
                table.insert(fileData, fields)
            end
            file:close()
        else
            fileData = fileInput
        end
    else
        fileData = fileOutput
    end
    return fileData
end

function GetSelectedTakeInformation(take)
    local selectedInfo = {}
    local data = findData()
    local currMode = tostring(math.floor(reaper.GetMediaItemTakeInfo_Value(take, "I_PITCHMODE")))
    for d = 1, #data do
        if data[d][1] == currMode then
            selectedInfo = data[d]
            break
        end
    end
    return selectedInfo
end

function GetModes()
    local mds = {}
    submodes = {}
    local data = findData()
    local m = 1
    local last = ''
    local max = 0
    for d = 2, #data do
        if #mds > 0 then
            if data[d][3] ~= last then
                mds[m - 1]["max"] = max
                mds[m] = {
                    ["label"] = data[d][3],
                    ["id"] = data[d][2],
                    ["max"] = 0
                }
                m = m + 1
                last = data[d][3]
                max = data[d][#data[d]]
            else
                if data[d][#data[d]] > max then
                    max = data[d][#data[d]]
                end
                if d == #data then
                    mds[m - 1]["max"] = max
                end
            end
        else
            mds[m] = {
                ["label"] = data[d][3],
                ["id"] = data[d][2],
                ["max"] = 0
            }
            last = data[d][3]
            m = m + 1
            max = data[d][#data[d]]
        end
    end
    return mds
end


----------------------------------------------------------------
----------------------------------------------------------------
--UI
----------------------------------------------------------------
----------------------------------------------------------------
package.path = reaper.GetResourcePath() .. '/Scripts/rtk/1/?.lua'
local rtk = require('rtk')
local log = rtk.log
--Main Window
win = rtk.Window{w=640, h=480, halign = 'center', title='WNL Change Pitch Algorithm'}
--Vertical Primary Container
local main = win:add(rtk.VBox{halign="center", vspacing = 10})
local modeSelect = main:add(rtk.OptionMenu{
    menu = GetModes()
})
local subContainer = main:add(rtk.FlowBox{vspacing=20, hspacing=20})

function AddSubModesMenu(count)
    for i = 1, count do
        
    end
end

if reaper.CountSelectedMediaItems() > 0 then
    local item = reaper.GetSelectedMediaItem(0, 0)
    local take = reaper.GetActiveTake(item)
    selectedInfo = GetSelectedTakeInformation(take)
    modeSelect:attr('selected', selectedInfo[2])
    -- Msg(modeSelect.selected_item().max)
end
modeSelect.onchange = function(self, item)
    local selected = item.id
    Msg(item.max)
    -- for i = 1, #selectedInfo - 4 do
        
    -- end
end

win:open()

----------------------------------------------------------------
----------------------------------------------------------------
--MAIN FUNCTION
----------------------------------------------------------------
----------------------------------------------------------------

selectedTake = ''

function MainFunction()
    if reaper.CountSelectedMediaItems() < 1 then goto finish end
    newMediaItem = reaper.GetSelectedMediaItem(0, 0)
    newTake = reaper.GetActiveTake(newMediaItem)
    if newTake == selectedTake then goto check end
    selectedTake = newTake
    selectedInfo = GetSelectedTakeInformation(selectedTake)
    modeSelect:attr('selected', selectedInfo[2])
    goto changed
    ::check::
    selectedInfo = GetSelectedTakeInformation(selectedTake)
    if selectedInfo[2] ~= modeSelect.selected then
        modeSelect:attr('selected', selectedInfo[2])
        -- Msg(modeSelect.selected_item.max)
        goto changed
    else goto finish
    end
    ::changed::

    ::finish::
    reaper.defer(MainFunction)
end

MainFunction()