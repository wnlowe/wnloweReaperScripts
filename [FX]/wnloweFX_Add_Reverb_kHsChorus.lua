chosenFX = "VST3:kHs Chorus"

function addSpecifiedFXToSelectedTrack()
    if reaper.CountSelectedTracks() < 1 then return end
    selectedTrack = reaper.GetSelectedTrack(0, 0)
    value = reaper.TrackFX_AddByName( selectedTrack, chosenFX, false, -1 )
    if value == -1 then reaper.ShowConsoleMsg("there is an issue with this fx")end
end

addSpecifiedFXToSelectedTrack()