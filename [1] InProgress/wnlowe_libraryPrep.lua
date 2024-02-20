----------------------------------------------------------
----------------------------------------------------------
--HELPERS
----------------------------------------------------------
----------------------------------------------------------
function Msg(variable)
    dbug = false
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
----------------------------------------------------------
----------------------------------------------------------
--FUNCTIONS
----------------------------------------------------------
----------------------------------------------------------
function MicConfigurationTranslation(original)
    local configuration = {
        ["Cardioid - Mono"] = "CARD",
        ["Supercardioid  - Mono"] = "SUPCARD",
        ["Hypercardioid  - Mono"] = "HYPCARD",
        ["Shotgun - Mono"] = "SHOT",
        ["Figure 8 - Mono"] = "FIG8",
        ["Omnidirectional - Mono"] = "OMNI",
        ["XY - Stereo"] = "XY",
        ["ORTF  - Stereo"] = "ORTF",
        ["AB Spaced Pair  - Stereo"] = "AB",
        ["Binaural - Stereo"] = "BIN",
        ["Mid-Side Raw"] = "MS-RAW",
        ["Mid-Side Decoded"] = "MS-DCOD",
        ["Double Mid-Side Raw"] = "DMS-RAW",
        ["Double Mid-Side Decoded"] = "DMS-DCOD",
        ["1st Order A Up - Ambisonic"] = "FOA-AFMT-UF",
        ["1st Order A Down - Ambisonic"] = "FOA-AFMT-DF",
        ["1st Order A End - Ambisonic"] = "FOA-AFMT-EF",
        ["1st Order B Ambix - Ambisonic"] = "FOA-AMBIX",
        ["1st Order B FuMa - Ambisonic"] = "FOA-FUMA",
        ["2nd Order A Up - Ambisonic"] = "SOA-AFMT-UF",
        ["2nd Order A Down - Ambisonic"] = "SOA-AFMT-DF",
        ["2nd Order A End - Ambisonic"] = "SOA-AFMT-EF",
        ["2nd Order B Ambix - Ambisonic"] = "SOA-AMBIX",
        ["2nd Order B FuMa - Ambisonic"] = "SOA-FUMA",
        ["LCR"] = "LCR",
        ["LRC"] = "LRC",
        ["Quad"] = "QUAD",
        ["Contact"] = "CNTCT",
        ["Hydrophone"] = "HYDRO",
        ["ElectroMagnetic"] = "EMF",
        ["Ultrasonic"] = "ULTRA",
        ["Infrasonic"] = "INFRA",
        ["Geophone"] = "GEO",
        ["Parabolic"] = "PARA",
        ["Jecklin"] = "OSS",
        ["Boundary"] = "BOUND",
    }
    if original == "" then
        return "RecType=;"
    else
        return "RecType=" .. configuration[original] .. ";"
    end
    
end

function MicPerspectiveTranslation(original, location)
    local perspective = {
        ["Close Up"] = "CU",
        ["Medium"] = "MED",
        ["Distant"] = "DST",
        ["Direct/DI"] = "D/I",
        ["Onboard"] = "OB",
        ["Various"] = "VARI",
        ["Contact"] = "CNTCT",
        ["Hydrophone"] = "HYDRO",
        ["Electromnagnetic"] = "EMF"
    }
    local interior = {
        ["Interior"] = "INT",
        ["Exterior"] = "EXT"
    }
    if original == "" then return "MicPerspective=;" end
    if location == "" then
        Output = "MicPerspective=" .. perspective[original] ..";"
    else
        Output = "MicPerspective=" .. perspective[original] .. " | " .. interior[location] .. ";"
    end
    return Output
end

function LibraryName(client, category)
    local head = ";Library="
    local sanzStart, sanzEnd = string.find(string.lower(client), "sanz")
    local cciStart, cciEnd = string.find(string.lower(client), "cci")
    local ccStart, ccEnd = string.find(string.lower(client), "cc")
    if sanzStart ~= nil then
        if category ~= "" then
            return head .. "Sanzaru - " .. category
        else
            return head .. "Sanzaru"
        end
    elseif cciStart ~= nil then
        if category ~= "" then
            return head .. "Clean Cuts Interactive - " .. category
        else
            return head .. "Clean Cuts Interactive"
        end
    elseif ccStart ~= nil then
        if category ~= "" then
            return head .. "Clean Cuts - " .. category
        else
            return head .. "Clean Cuts"
        end
    else
        return head .. category
    end
end

function LibraryAbr(client, abrv)
    local sanzStart, sanzEnd = string.find(string.lower(client), "sanz")
    local cciStart, cciEnd = string.find(string.lower(client), "cci")
    local ccStart, ccEnd = string.find(string.lower(client), "cc")
    if sanzStart ~= nil then
        if abrv ~= "" then
            return "_SANZ_" .. abrv
        else
            return "_SANZ"
        end
    elseif cciStart ~= nil then
        if abrv ~= "" then
            return "_CCI_" .. abrv
        else
            return "_CCI"
        end
    elseif ccStart ~= nil then
        if abrv ~= "" then
            return "_CC_" .. abrv
        else
            return "_CC"
        end
    else
        if abrv ~= "" then
            return "_" .. abrv
        else
            return ""
        end
    end
    -- "_SANZ_" .. abrv
end

function CatIDControl(idInput)
    if idInput == "" then return "DSGNMisc-" 
    else return idInput .. "-"end
end

function RegionColor(region)
    if region:gsub(" ", "") == "48k" or region:gsub(" ", "") == "48" or region:gsub(" ", "") == "48000" then return reaper.ColorToNative(255, 0, 0)|0x1000000
    elseif region:gsub(" ", "") == "96k" or region:gsub(" ", "") == "96" or region:gsub(" ", "") == "96000" then return reaper.ColorToNative(0, 255, 0)|0x1000000
    elseif region:gsub(" ", "") == "192k" or region:gsub(" ", "") == "192" or region:gsub(" ", "") == "192000" then return reaper.ColorToNative(0, 0, 255)|0x1000000
    else return 0
    end
end
----------------------------------------------------------
----------------------------------------------------------
--Main
----------------------------------------------------------
----------------------------------------------------------
--CSV Prep
----------------------------------------------------------
r, csv = reaper.JS_Dialog_BrowseForOpenFiles( "Library Helper CSV", "Downloads", "Library Metadata Template.csv", "CSV\0*.csv", false )
if r < 1 then reaper.ReaScriptError( "!No CSV was selected" ) end

fileOutput = {}
local file = assert(io.open(csv, "r"))
for line in file:lines() do
    fields = line:split(',')
    table.insert(fileOutput, fields)
end
file:close()
----------------------------------------------------------
--Item Prep
----------------------------------------------------------
numItems = reaper.CountSelectedMediaItems(0)
if numItems ~= #fileOutput - 16 then reaper.ReaScriptError( "!Incorrect number of items Selected" ) end

--Correctly space out
for i = 1, numItems - 1 do
    local item = reaper.GetSelectedMediaItem( 0, i )
    local previousItem = reaper.GetSelectedMediaItem(0, i - 1)
    local previousStart = reaper.GetMediaItemInfo_Value(previousItem, "D_POSITION")
    local previousLength = reaper.GetMediaItemInfo_Value(previousItem, "D_LENGTH")
    local newStart = previousStart + previousLength + 1
    reaper.SetMediaItemInfo_Value(item, "D_POSITION", newStart)
    -- if i == numItems - 1 then
    --     local idx = reaper.AddProjectMarker(0, true, newStart, newStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH"), "", -1)
    -- end
    -- local idx = reaper.AddProjectMarker(0, true, previousStart, previousStart + previousLength, "", -1)
end
----------------------------------------------------------
--Metadata processing
----------------------------------------------------------
for i = 0, numItems - 1 do
    METASTRING = "META;CatID=;Category=;SubCategory=;"
    local item = reaper.GetSelectedMediaItem( 0, i )
    local start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local full = reaper.GetMediaItemInfo_Value(item, "D_POSITION") + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local take = reaper.GetTake(item, 0)
    local r, name = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "", false)
    name = name:gsub(".wav", "")
    name = name:gsub(".WAV", "")
    row = ""
    for j = 1, #fileOutput do
        sourcename = fileOutput[j][1]:gsub(".wav", "")
        sourcename = sourcename:gsub(".WAV", "")
        if sourcename == name then
            row = j
            goto continue
        end
    end
    reaper.ReaScriptError( "No row match was found for file " .. i .. ", continuing" )
    goto final
    ::continue::
    Msg(fileOutput[row][1])
    fileName = fileOutput[row][4]:gsub("_", " ")
    fileName = fileName:gsub("-", " ")
    METASTRING = METASTRING .. "UserCategory=" .. string.upper(fileOutput[row][3]) .. ";VendorCategory=;FXNAME=" .. fileName ..";Notes=;Show=;CategoryFull=;TrackTitle=" .. string.upper(fileName) ..
                    ";Description=" .. fileOutput[row][5]:gsub(";", ",") .. ";Keywords=" .. fileOutput[row][6]:gsub(";", ",") .. ";RecMedium=" .. fileOutput[row][13]:gsub(";", ",") ..
                    LibraryName(fileOutput[1][1], fileOutput[row][7]:gsub(";", ",")) .. ";Location=" .. fileOutput[row][14]:gsub(";", ",") .. ";URL=;Manufacturer=;MetaNotes=;" ..
                    MicPerspectiveTranslation(fileOutput[row][11], fileOutput[row][12]) .. MicConfigurationTranslation(fileOutput[row][10]) ..
                    "Microphone=" .. fileOutput[row][9] .. ";Designer=" .. fileOutput[row][15] .. ";ShortID=;"
    local idx = reaper.AddProjectMarker( 0, false, start, start, METASTRING, 0 )
    local idx = reaper.AddProjectMarker(0, false, start + 0.001, start + 0.001, "META", 0)
    local idx = reaper.AddProjectMarker2(0, true, start, full, CatIDControl(fileOutput[row][2]) .. string.upper(fileOutput[row][3]) .. "_" .. fileName .. LibraryAbr(fileOutput[1][1], fileOutput[row][8]), -1, RegionColor(fileOutput[row][16]) )

    -- local r, name2 = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", name .. "_" .. fileOutput[row][12], true)
    ::final::
end

reaper.Main_OnCommand(40326, 0) -- View: Show region/marker manager window
-- METASTRING = "META;CatID=;Category=;SubCategory=;UserCategory=;VendorCategory=;"