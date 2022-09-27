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
function Msg(variable) reaper.ShowConsoleMsg(tostring(variable) .. "\n") end

-- Two equations that via recursion showed the best lines of fit in their ranges
-- Data pulled from straight insertion and recording
function dBToAutomation(x)
    if x > -23.1 then
        return 714.7520864 + 21.62084026 * x + 0.1907747361 * x ^ (2)
    else
        return 702.833988 * 1.035972147 ^ (x)
    end
end

-- Writes the automation points on the take envelope
function SetVolumePoints(mi, c, db)
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEENV1"), 0) -- get take
    local env = reaper.GetTakeEnvelopeByName(reaper.GetActiveTake(mi), "Volume") -- get volume envelope
    Mode = reaper.GetEnvelopeScalingMode(env)
    local ct = c / 2 -- cycle length / 2 to get time between points
    local value = dBToAutomation(tonumber(db))
    for k = 0, NumCycles * 2 + 1 do
        if k % 2 == 0 then
            vol = value
        else
            vol = 716.21785031263
        end
        reaper.InsertEnvelopePoint(env, c * k, vol, 0, 0, false)
    end
end

----------------------------------------------------------------
----------------------------------------------------------------
-- Main
----------------------------------------------------------------
----------------------------------------------------------------

-- Find all items
SelItemCount = reaper.CountSelectedMediaItems(0)
-- Find lengths of items
LongestKey = nil
Items = {}
for i = 1, SelItemCount do
    local sel = reaper.GetSelectedMediaItem(0, i - 1)
    Items[sel] = reaper.GetMediaItemInfo_Value(sel, "D_LENGTH")
    if not LongestKey then
        LongestKey = sel
    else
        if Items[sel] > Items[LongestKey] then LongestKey = sel end
    end
end
-- Get User Input and parse it
local continue, Cycles = reaper.GetUserInputs("Volume Cycle Count", 2,
                                              "How Many Volume Cycles? , Max Volume in dBs: extrawidth=150",
                                              "")
if not continue or Cycles == "" then return end
CycleResponse = {}
for match in (Cycles .. ","):gmatch("(.-),") do
    table.insert(CycleResponse, match)
end
for i = 1, #CycleResponse do
    if i == 1 then
        NumCycles = CycleResponse[i]
    elseif i == 2 then
        MaxVol = CycleResponse[i]
    end
end
CycleLength = Items[LongestKey] / NumCycles
-- Do processing on the longest item
SetVolumePoints(LongestKey, CycleLength, MaxVol)

----------------------------------------------------------------
----------------------------------------------------------------
-- NOTES
----------------------------------------------------------------
----------------------------------------------------------------
--[[
    [] Work for selecting multiple items and offsetting
    [] Notate all of code
]]
