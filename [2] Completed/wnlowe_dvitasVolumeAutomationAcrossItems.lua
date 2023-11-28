-- Using Take Volume to fade up and down items. Developed for Game Audio Ambiences. 
-- Idea by David Vitas
-- V 0.5
-- By William N. Lowe
-- wnlsounddesign.com
----------------------------------------------------------------
----------------------------------------------------------------
-- Release Notes
----------------------------------------------------------------
----------------------------------------------------------------
--[[
    V0.5:
    [x] Found best available function for best fit of dB to Automation
]] -------------------------------------------------------------
----------------------------------------------------------------
-- FUNCTIONS
----------------------------------------------------------------
----------------------------------------------------------------
-- Msg function from marc carlton
Ifdebug = false
function Msg(variable) if Ifdebug then reaper.ShowConsoleMsg(tostring(variable) .. "\n") end end

-- Two equations that via recursion showed the best lines of fit in their ranges
-- Data pulled from straight insertion and recording
function dBToAutomation(x)
    if x == 0 then return 716.21785031263
    elseif x > -23.1 then
        return 714.7520864 + 21.62084026 * x + 0.1907747361 * x ^ (2)
    else
        return 702.833988 * 1.035972147 ^ (x)
    end
end

-- Writes the automation points on the take envelope
function SetVolumePoints(currentMediaItem, point, dbMax, dbMin)
    
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEENV1"), 0) -- get take
    SelectedTake = reaper.GetActiveTake(currentMediaItem)
    -- retval, stringNeedBig = reaper.GetSetMediaItemTakeInfo_String( SelectedTake, "P_NAME")
    -- Msg(stringNeedBig)
    local env = reaper.GetTakeEnvelopeByName(SelectedTake, "Volume") -- get volume envelope
    Mode = reaper.GetEnvelopeScalingMode(env)
    -- local ct = c / 2 -- cycle length / 2 to get time between points
    local valueMax = dBToAutomation(tonumber(dbMax))
    local valueMin = dBToAutomation(tonumber(dbMin))
    -- local lowerDbValue = 716.21785031263

    local itemLength = reaper.GetMediaItemInfo_Value(currentMediaItem, "D_LENGTH")
    Msg(Offset)
    if Offset == 2 then
        rpidx = reaper.GetEnvelopePointByTimeEx( env, 0, 0 )
        Msg(rpidx)
        reaper.SetEnvelopePointEx(env, rpidx, 0, 0, valueMax)
    end
    pointCount = 1
    while point[pointCount] < itemLength do
        if pointCount % 2 == 0 then
            vol = valueMax
        else
            vol = valueMin
        end
        Msg("Adding " .. vol)
        reaper.InsertEnvelopePoint(env, point[pointCount], vol, 0, 0, false, true)
        pointCount = pointCount + 1
    end
    if point[pointCount - 1] ~= itemLength then
        if vol == valueMax then reaper.InsertEnvelopePoint(env, itemLength, valueMin, 0, 0, false, true)
        else reaper.InsertEnvelopePoint(env, itemLength, valueMax, 0, 0, false, true) end
    end
    reaper.Envelope_SortPoints(env)
    -- for i = 0, # do
    --     if k % 2 == 0 then
    --         vol = value
    --     else
    --         vol = 716.21785031263
    --     end
    --     reaper.InsertEnvelopePoint(env, c * k, vol, 0, 0, false)
    -- end
end

----------------------------------------------------------------
----------------------------------------------------------------
-- Main
----------------------------------------------------------------
----------------------------------------------------------------
reaper.Undo_BeginBlock()
-- Find all items
SelItemCount = reaper.CountSelectedMediaItems(0)
-- Find lengths of items
LongestKey = nil
Items = {}
for i = 1, SelItemCount do
    local sel = reaper.GetSelectedMediaItem(0, i - 1)
    Items[i] = {
        ["itemID"] = sel,
        ["itemLength"] = reaper.GetMediaItemInfo_Value(sel, "D_LENGTH")
    }
    if not LongestKey then
        LongestKey = i
    else
        if Items[i]["itemLength"] > Items[LongestKey]["itemLength"] then LongestKey = i end
    end
end
-- Get User Input and parse it
local continue, Cycles = reaper.GetUserInputs("Volume Cycle Count", 3,
                                              "Number of Cycles: ,Offset Volume in dBs: , Start Point: extrawidth=150",
                                              "")
if not continue or Cycles == "" then return end
CycleResponse = {}
for match in (Cycles .. ","):gmatch("(.-),") do
    table.insert(CycleResponse, match)
end
-- for i = 1, #CycleResponse do
--     if i == 1 then
--         NumCycles = CycleResponse[i]
--     elseif i == 2 then
--         MaxVol = CycleResponse[i]
--     end
-- end
if CycleResponse[1] == "" then NumCycles = 9
else NumCycles = CycleResponse[1] end
Offset = 1
if CycleResponse[3] ~= "" then Offset = tonumber(CycleResponse[3]) end
if Offset == 1 then
    if CycleResponse[2] == "" then
        MaxVol = 0
        MinVol = -30
    else
        MaxVol = 0
        MinVol = CycleResponse[2]
    end
else
    if CycleResponse[2] == "" then
        MaxVol = -30
        MinVol = 0
    else
        MaxVol = CycleResponse[2]
        MinVol = 0
    end
end

CycleLength = Items[LongestKey]["itemLength"] / (NumCycles * 2)

PointLocations = {}
for i = 1, NumCycles * 2 do
    PointLocations[i] = CycleLength * i
end
-- Do processing on the longest item
Msg(#PointLocations)
for i = 1, #Items do
    SetVolumePoints(Items[i]["itemID"], PointLocations, MaxVol, MinVol)
end

reaper.Undo_EndBlock( "wnlowe_dvitas Volume Automation", 0 )
----------------------------------------------------------------
----------------------------------------------------------------
-- NOTES
----------------------------------------------------------------
----------------------------------------------------------------
--[[
    [] Work for selecting multiple items and offsetting
    [] Notate all of code
]]
