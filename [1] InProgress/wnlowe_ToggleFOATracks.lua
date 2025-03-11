Ifdebug = false
function Msg(variable) if Ifdebug then reaper.ShowConsoleMsg(tostring(variable) .. "\n") end end

local _, _, sec, command = reaper.get_action_context()
local fState = reaper.GetToggleCommandStateEx(0, command) == 1 and 0 or 1
Msg(fState)

reaper.SetToggleCommandState(sec, command, fState)


local function findFOATrack()
    local fNumTracks = reaper.CountTracks(0)
    for i = 0, fNumTracks - 1 do
        Msg(i)
        local r, fName = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0, i), "P_NAME", "", false)
        Msg(fName)
        if fName == "FOA Decode" and reaper.TrackFX_GetByName( reaper.GetTrack(0, i), "SoundField By RODE", false ) ~= -1 then
            return reaper.GetTrack(0, i)
        end
    end
end

local function findChildrenTracks(fFOA)
    local fNumTracks = reaper.CountTracks(0)
    local fT = {}
    for i = 0, fNumTracks - 1 do
        local fTr = reaper.GetTrack(0, i)
        if reaper.GetParentTrack(fTr) == fFOA then
            table.insert(fT, fTr)
        end
    end
    return fT
end

local function isFOATrackVisible(fTrack)
    local fVisible = reaper.GetMediaTrackInfo_Value(fTrack, "B_SHOWINTCP")
    return fVisible
end

-- local function dMain(fTrack, dVisibility)
--     if isFOATrackVisible(fTrack) == 1 then
--         dVisibility = 1
--         reaper.SetToggleCommandState(sec, command, 1)
--     else
--         dVisibility = 0
--         reaper.SetToggleCommandState(sec, command, 0)
--     end
--     reaper.defer(dMain(fTrack, dVisibility))
-- end

local fTrack = findFOATrack()
local fChildren = {}
fChildren = findChildrenTracks(fTrack)


if fState == 1 then
    reaper.SetMediaTrackInfo_Value(fTrack, "B_SHOWINTCP", 1)
    for i = 1, #fChildren do
        reaper.SetMediaTrackInfo_Value(fChildren[i], "B_SHOWINTCP", 1)
    end
else
    reaper.SetMediaTrackInfo_Value(fTrack, "B_SHOWINTCP", 0)
    for i = 1, #fChildren do
        reaper.SetMediaTrackInfo_Value(fChildren[i], "B_SHOWINTCP", 0)
    end
end

-- reaper.defer(dMain(fTrack, fState))