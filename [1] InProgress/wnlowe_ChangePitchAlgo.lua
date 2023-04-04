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

--File or Directory helper functions
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

function readModes()
    local data = {{}}
    local mode_idx = 0
    local submode_idx = 0
    m = 1
    while true do
        local mode_ret, mode_str = reaper.EnumPitchShiftModes(mode_idx)
        if not mode_ret then break end
        if mode_str and mode_str:len() > 0 then
            data[m][1] = mode_str
            s = 2
            local continue = true
            while continue do
                local submode_str = reaper.EnumPitchShiftSubModes(mode_idx, submode_idx)
                if submode_str and submode_str:len() > 0 then
                    -- local row = {[mode_str] = submode_str}
                    -- table.insert(data, mode_str)
                    -- table.insert()
                    data[m][s] = submode_str
                -- reaper.ShowConsoleMsg(mode_str .. " - " .. submode_str .. "\n")
                    submode_idx = submode_idx + 1
                    s = s + 1
                else
                    submode_idx = 0
                    continue = false
                end
            end
            m = m + 1
        end
        mode_idx = mode_idx + 1 
    end
    return data
end

function writeData(csv)
    fileInput = {}
    fileInput = readModes()
    local file = assert(io.open(csv, "w"))
    file:write("Version,"..version..'\n')
    Msg(fileInput[1][1])
    for i = 1, #fileInput do
        for j = 1, #fileInput[i] do
            if j > 1 then file:write(',') end
            if fileInput[i][j] ~= nil then
                file:write(fileInput[i][j])
            end
        end
        file:write('\n')
    end
    file:close()
end

csvName = 'PitchAlgoOptions.csv'
version =  reaper.GetAppVersion()

if not exists(csvName) then
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
        writeData(csvName)
    end
end