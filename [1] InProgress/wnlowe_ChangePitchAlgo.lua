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
    local readData = {}
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
        table.insert(readData, fields)
    end
    return readData
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
    if Data == nil or Data == {} or #Data == 0 then Data = findData() end
    local currMode = tostring(math.floor(reaper.GetMediaItemTakeInfo_Value(take, "I_PITCHMODE")))
    for d = 1, #Data do
        if Data[d][1] == currMode then
            selectedInfo = Data[d]
            break
        end
    end
    return selectedInfo
end

function GetModes()
    local mds = {}
    submodes = {}
    if Data == nil or Data == {} or #Data == 0 then Data = findData() end
    local m = 1
    local last = ''
    local max = 0
    for d = 2, #Data do
        if #mds > 0 then
            if Data[d][3] ~= last then
                mds[m - 1]["max"] = max
                mds[m] = {
                    ["label"] = Data[d][3],
                    ["id"] = Data[d][2],
                    ["max"] = 0
                }
                m = m + 1
                last = Data[d][3]
                max = Data[d][#Data[d]]
            else
                if Data[d][#Data[d]] > max then
                    max = Data[d][#Data[d]]
                end
                if d == #Data then
                    mds[m - 1]["max"] = max
                end
            end
        else
            mds[m] = {
                ["label"] = Data[d][3],
                ["id"] = Data[d][2],
                ["max"] = 0
            }
            last = Data[d][3]
            m = m + 1
            max = Data[d][#Data[d]]
        end
    end
    return mds
end

function GetFirstSubModeMenu()
    local containerSize = subContainer.children
    if #containerSize > 0 then subContainer:remove_all() end
    if Data == nil or Data == {} or #Data == 0 then Data = findData() end
    local found = false
    local menuModes = {}
    for a = 1, #Data do
        if Data[a][2] == ActiveMode then
            if not found then found = true end
            if #menuModes > 0 then
                for i = 1, #menuModes do
                    if menuModes[i] == Data[a][5] then goto alreadyInTable end
                end
            end
            table.insert(menuModes, Data[a][5])
            ::alreadyInTable::
        elseif found then break end
    end
    local subMenuConfig = {}
    for i = 1, #menuModes do
        subMenuConfig[i] = {
            ["label"] = menuModes[i],
            ["id"] = menuModes[i]
        }
    end
    return subMenuConfig
end

function NilSM(instance)
    ActiveMode = selectedInfo[2]
    NumSubModes = selectedDepth
    if instance == 1 then 
        subModeSelect = subContainer:add(rtk.OptionMenu{
            menu = GetFirstSubModeMenu()
        })

        subModeSelect.onchange = function(self, item)
            local selfidx = subContainer:get_child_index(self)
            Msg('idx = '..selfidx)
        end
    else

    end
    return subContainer:get_child(instance)
end


function AdditionalSubModes(idx)
    local selfidx = idx
    Msg(selfidx)
    local topMode = selectedInfo[2]
    local higherSubs = {}
    for i = 1, selfidx - 1 do
        local child = subContainer:get_child(i)
        table.insert(higherSubs, child.selected)
    end
    if higherSubs == {} then Msg('PROBLEM HERE') end
    for i = 1, #Data do
        if Data[i][2] == topMode then
            for j = 1, #higherSubs do
                if Data[i][4+j] ~= higherSubs[j] then goto next end
            end
            local a = 0
            local newMenuValues = {}
            -- while Data[i + a][4 + #higherSubs] == higherSubs[#higherSubs] do
            --     table.insert(newMenuValues, Data[i + a][4 + #higherSubs + 1])
            --     a = a + 1
            -- end
            for a = i, #Data do
                Msg(higherSubs[#higherSubs])
                if Data[a][4 + #higherSubs] == higherSubs[#higherSubs] then
                    table.insert(newMenuValues, Data[i + a][4 + #higherSubs + 1])
                end
                if Data[a][2] ~= selectedInfo[2] then break end
            end
            newMenu = {}
            for j = 1, #newMenuValues do
                Msg(newMenuValues[j])
                newMenu[j] = {
                    ["label"] = newMenuValues[j],
                    ["id"] = newMenuValues[j]
                }
            end
            Msg("success")
            return newMenu
        end
        ::next::
    end
    Msg('idx = '..selfidx)
end

function AddSubMenu()
    local depthTable = subContainer.children
    local depth = #depthTable + 1
    local maxDepth = selectedInfo[#selectedInfo]
    if depth == 1 then
        
    end
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
subContainer = main:add(rtk.FlowBox{vspacing=20, hspacing=20})

if reaper.CountSelectedMediaItems() > 0 then
    SelectedItem = reaper.GetSelectedMediaItem(0, 0)
    SelectedTake = reaper.GetActiveTake(SelectedItem)
    selectedInfo = GetSelectedTakeInformation(SelectedTake)
    modeSelect:attr('selected', selectedInfo[2])
    -- Msg(modeSelect.selected_item().max)
end

modeSelect.onchange = function(self, item)
    ActiveMode = item.id
    NumSubModes = item.max
    Msg(item.max)
    for i = 1, #Data do
        if Data[i][2] == ActiveMode then
            reaper.SetMediaItemTakeInfo_Value(SelectedTake, "I_PITCHMODE", Data[i][1])
            selectedInfo = GetSelectedTakeInformation(selectedTake)
            local containerSize = subContainer.children
            if #containerSize > 0 then subContainer:remove_all() end
            break
        end
    end
    self:attr('selected', selectedInfo[2])

    for i = 1, selectedInfo[#selectedInfo] do
        subModeSelect = subContainer:add(rtk.OptionMenu{
            menu = AddSubMenu()
        })

        subModeSelect.onchange = function(self, item)
            local name = item.id
            
        end
    end
    -- Msg("Hello")
    -- subModeSelect = subContainer:add(rtk.OptionMenu{
    --     menu = GetFirstSubModeMenu()
    -- })
    -- if tonumber(selectedInfo[#selectedInfo]) > 1 then
    --     for i = 2, selectedInfo[#selectedInfo] do
    --         subModeSelect = subContainer:add(rtk.OptionMenu{
    --             menu = AdditionalSubModes(i)
    --         })
    --     end
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
    Msg('Reselected')
    selectedDepth = selectedInfo[#selectedInfo]
    for i = 1, #selectedDepth do
        local sm = subContainer:get_child(i)
        if sm == nil then
            sm = NilSM(i)
        end
        Msg(selectedInfo[i + 4])
        sm:attr('selected', selectedInfo[i + 4])
    end
    goto changed
    ::check::
    selectedInfo = GetSelectedTakeInformation(selectedTake)
    --Somehow I need to check the final value of what is created by the current selected options
        --against what the selected item's is
    
    if selectedInfo[2] ~= modeSelect.selected then
        modeSelect:attr('selected', selectedInfo[2])
        selectedDepth = selectedInfo[#selectedInfo]
        for i = 1, #selectedDepth do
            local sm = subContainer:get_child(i)
            if sm == nil then
                sm = NilSM(i)
            end
            Msg(selectedInfo[i + 4])
            sm:attr('selected', selectedInfo[i + 4])
        end
        -- Msg(modeSelect.selected_item.max)
        goto changed
    else goto finish
    end
    ::changed::

    ::finish::
    reaper.defer(MainFunction)
end

MainFunction()