Ifdebug = false
function Msg(variable) if Ifdebug then reaper.ShowConsoleMsg(tostring(variable) .. "\n") end end

local _, _, sec, command = reaper.get_action_context()
local zState = reaper.GetToggleCommandStateEx(0, command) == 1 and 0 or 1
Msg(zState)

reaper.SetToggleCommandState(sec, command, zState)


local function findZoomTrack()
    local zNumTracks = reaper.CountTracks(0)
    for i = 0, zNumTracks - 1 do
        Msg(i)
        local r, zName = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0, i), "P_NAME", "", false)
        Msg(zName)
        if zName == "Zoom" then
            return reaper.GetTrack(0, i)
        end
    end
end

local function findChildrenTracks(zTrack)
    local zNumTracks = reaper.CountTracks(0)
    local zT = {}
    for i = 0, zNumTracks - 1 do
        local zTr = reaper.GetTrack(0, i)
        if reaper.GetParentTrack(zTr) == zTrack then
            table.insert(zT, zTr)
        end
    end
    return zT
end

local function isZoomTrackVisible(zTrack)
    local zVisible = reaper.GetMediaTrackInfo_Value(zTrack, "B_SHOWINTCP")
    return zVisible
end

-- local function dMain(zTrack, dVisibility)
--     if isFOATrackVisible(zTrack) == 1 then
--         dVisibility = 1
--         reaper.SetToggleCommandState(sec, command, 1)
--     else
--         dVisibility = 0
--         reaper.SetToggleCommandState(sec, command, 0)
--     end
--     reaper.defer(dMain(zTrack, dVisibility))
-- end

local zTrack = findZoomTrack()
local zChildren = {}
zChildren = findChildrenTracks(zTrack)


if zState == 1 then
    reaper.SetMediaTrackInfo_Value(zTrack, "B_SHOWINTCP", 1)
    for i = 1, #zChildren do
        reaper.SetMediaTrackInfo_Value(zChildren[i], "B_SHOWINTCP", 1)
    end
else
    reaper.SetMediaTrackInfo_Value(zTrack, "B_SHOWINTCP", 0)
    for i = 1, #zChildren do
        reaper.SetMediaTrackInfo_Value(zChildren[i], "B_SHOWINTCP", 0)
    end
end

-- reaper.defer(dMain(zTrack, zState))