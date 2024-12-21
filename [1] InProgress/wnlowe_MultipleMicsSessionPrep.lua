

function Msg(variable)
    dbug = true
    if dbug then reaper.ShowConsoleMsg(tostring (variable).."\n") end
end

function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        -- Msg(str)
        table.insert(t, str)
    end
    return t
end

retval, folder = reaper.JS_Dialog_BrowseForFolder( "Source Audio Files", [[C:\Users\ccuts\Downloads\Sanzaru_Archives_Dec_Foley_Water\Audio Files]] )

index = 0
SourceFiles = {}
file = reaper.EnumerateFiles(folder, index)
while file ~= nil do
    file = reaper.EnumerateFiles(folder, index)
    if file ~= nil then
        local filenameSplit = split(file, '.')
        filename = ''
        for n=1, #filenameSplit do
            if n ~= #filenameSplit then
                filename = filename .. filenameSplit[n]
                -- Msg(filename)
            else
                ext = filenameSplit[n]
            end
        end
        SourceFiles[index] = filename
    end
    index = index + 1
end

SortFiles = {}
FileKeys = {}

for j = 0, #SourceFiles do

    f = SourceFiles[j]
    if f == nil then goto skip end
    fSplit = split(f, "_")
    fName = fSplit[#fSplit - 1]
    fNameSplit = split(fName, " ")
    fMatch = ''
    m = 1
    while m < #fSplit - 1 do
        if m > 1 then fMatch = fMatch .. '_' end
        fMatch = fMatch .. fSplit[m]
        m = m + 1
    end

    if #fNameSplit > 2 then
        o = 1
        fMatch = fMatch .. '_'
        while o < #fNameSplit do
           fMatch = fMatch .. fNameSplit[o]
           o = o + 1
        end
        fMatch = fMatch .. '_' .. fSplit[#fSplit]
    else
        fName = fMatch .. '_' .. fNameSplit[1] .. '_' .. fSplit[#fSplit]
        fmic = fNameSplit[2]
    end
    -- Msg(fMatch)
    -- fNext, fCut = f:match'(.*_)(.*)'
    -- fCut, fFinal = fNext:match'(.*_)(.*)'
    -- fCut, fmic = fFinal:match'(.*?)(.*)'
    -- fName, fCut = fNext:match'(.*?)(.*)'

    if SortFiles[fName] == nil then
        SortFiles[fName] = {}
        FileKeys[#FileKeys+1] = fName
    end
    -- table.insert(SortFiles[fName], fmic)
    SortFiles[fName][fmic] = f
    ::skip::
end

reaper.InsertTrackAtIndex( 0, true )
reaper.InsertTrackAtIndex( 1, true )
reaper.InsertTrackAtIndex( 2, true )
reaper.InsertTrackAtIndex( 3, true )

parent = reaper.GetTrack(0, 0)
t8040 = reaper.GetTrack(0, 1)
reaper.GetSetMediaTrackInfo_String(t8040, "P_NAME", "8040", true)
tSanken = reaper.GetTrack(0, 2)
reaper.GetSetMediaTrackInfo_String(tSanken, "P_NAME", "Sanken", true)
tHydro = reaper.GetTrack(0, 3)
reaper.GetSetMediaTrackInfo_String(tHydro, "P_NAME", "Hydrophone", true)

reaper.SetMediaTrackInfo_Value( parent, "I_FOLDERDEPTH", 1 )

startTime = 1
MediaItemIndex = 0
-- MediaItemIndex = {
--     ["8040"] = 0,
--     ["Hydrophone"] = 0,
--     ["SANKEN"] = 0
-- }
local time = 1
for i=0, #FileKeys do
    local key = FileKeys[i]
    Msg(key)
    
    local lengths = {}
    if type(SortFiles[key]) ~= "table" then goto notTable end
    for k, v in pairs(SortFiles[key]) do
        if k == "8040" then
            reaper.SetOnlyTrackSelected( t8040 )
        elseif k == 'Hydrophone' then
            reaper.SetOnlyTrackSelected( tHydro )
        elseif k == 'SANKEN' then
            reaper.SetOnlyTrackSelected( tSanken )
        end
        reaper.InsertMedia( folder .. [[\]] .. v .. '.wav', 0 )
        mi = reaper.GetMediaItem(0, MediaItemIndex)
        
        sourceTime, r = reaper.GetMediaSourceLength( reaper.GetMediaItemTake_Source( reaper.GetActiveTake( mi ) ) )
        table.insert(lengths, sourceTime)
        reaper.SetMediaItemInfo_Value(mi, "D_POSITION", time)

        
        
        MediaItemIndex = MediaItemIndex + 1
    end

    table.sort(lengths)
    time = time + 3 + lengths[#lengths]
    reaper.SetEditCurPos( time, true, true )
    ::notTable::
end

-- reaper.InsertMedia( file, mode )



--[[
WATER_LargeObject_Splash Hydrophone_05  >> WATER_LargeObject_Splash_05 && Hydrophone
WATER_LargeObject_Splash SANKEN_05      >> WATER_LargeObject_Splash_05 && SANKEN
WATER_LargeObject_Splash 8040_05        >> WATER_LargeObject_Splash_05 && 8040
]]