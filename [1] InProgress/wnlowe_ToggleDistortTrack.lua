Ifdebug = false
function Msg(variable) if Ifdebug then reaper.ShowConsoleMsg(tostring(variable) .. "\n") end end

local _, _, sec, command = reaper.get_action_context()
local dState = reaper.GetToggleCommandStateEx(0, command) == 1 and 0 or 1
Msg(dState)

reaper.SetToggleCommandState(sec, command, dState)


local function findDistortTrack()
    local dNumTracks = reaper.CountTracks(0)
    for i = 0, dNumTracks - 1 do
        Msg(i)
        local r, dName = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0, i), "P_NAME", "", false)
        Msg(dName)
        if dName == "Distort" and reaper.TrackFX_GetByName( reaper.GetTrack(0, i), "distort_output", false ) ~= -1 then
            return reaper.GetTrack(0, i)
        end
    end
end

local function isDistortTrackVisible(dTrack)
    local dVisible = reaper.GetMediaTrackInfo_Value(dTrack, "B_SHOWINTCP")
    return dVisible
end

-- local function dMain(dTrack, dVisibility)
--     if isDistortTrackVisible(dTrack) == 1 then
--         dVisibility = 1
--         reaper.SetToggleCommandState(sec, command, 1)
--     else
--         dVisibility = 0
--         reaper.SetToggleCommandState(sec, command, 0)
--     end
--     reaper.defer(dMain(dTrack, dVisibility))
-- end

local dTrack = findDistortTrack()

if dState == 1 then
    reaper.SetMediaTrackInfo_Value(dTrack, "B_SHOWINTCP", 1)
else
    reaper.SetMediaTrackInfo_Value(dTrack, "B_SHOWINTCP", 0)
end

-- reaper.defer(dMain(dTrack, dState))