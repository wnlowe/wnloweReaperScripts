----------------------------------------------------------
----------------------------------------------------------
--HELPERS
----------------------------------------------------------
----------------------------------------------------------
function Msg(variable)
    dbug = false
    if dbug then reaper.ShowConsoleMsg(tostring (variable).."\n") end
end

AssignTracks = false

function GetSelectedTracks()
    AssignTracks = true
    SelectedTracks = {}
    for i = 0, NumTracks - 1 do
       SelectedTracks[i] = reaper.GetSelectedTrack( 0, i + 1 )
    end
end

function AddSends()
    local targetTrack = reaper.GetTrack( 0, reaper.CountTracks( 0 ) )
    for i = 0, #SelectedTracks do
        local newSend = reaper.CreateTrackSend( SelectedTracks[i], targetTrack )
        reaper.SetTrackSendInfo_Value( SelectedTracks[i], 0, newSend, "D_VOL", 1.0 )
    end
end

NumTracks = reaper.CountSelectedTracks(0)
if NumTracks > 0 then GetSelectedTracks() end
for j = 1, NumTracks do reaper.SetTrackSelected( reaper.GetSelectedTrack(0, j), false ) end
reaper.SetTrackSelected(reaper.GetTrack( 0, reaper.CountTracks( 0 ) ), true)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_ADD_TRTEMPLATE1"), 0) -- SWS/S&M: Resources - Import tracks from track template, slot 1
if AssignTracks then AddSends() end