Ifdebug = false
function Msg(variable) if Ifdebug then reaper.ShowConsoleMsg(tostring(variable) .. "\n") end end

local hNumTracks = reaper.CountSelectedTracks(0)
local hSelectedTracks = {}
local hHidden = false
for i = 0, hNumTracks - 1 do
    table.insert(hSelectedTracks, reaper.GetSelectedTrack( 0, i ))
    if reaper.GetMediaTrackInfo_Value(reaper.GetSelectedTrack( 0, i ), "B_SHOWINTCP") == 0 then hHidden = true end
end

if hHidden then
    for i = 1, #hSelectedTracks do
        reaper.SetMediaTrackInfo_Value(hSelectedTracks[i], "B_SHOWINTCP", 1)
    end
else
    for i = 1, #hSelectedTracks do
        reaper.SetMediaTrackInfo_Value(hSelectedTracks[i], "B_SHOWINTCP", 0)
    end
end
