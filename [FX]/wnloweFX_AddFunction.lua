local arg={...}
function addSpecifiedFXToSelectedTrack(chosenFX)
    numSelected = reaper.CountSelectedTracks()
    if numSelected < 1 then return end
    for i = 0, numSelected - 1, 1 do
        selectedTrack = reaper.GetSelectedTrack(0, i)
        value = reaper.TrackFX_AddByName(selectedTrack, chosenFX, false, -1 )
        if value == -1 then reaper.ShowConsoleMsg("there is an issue with this fx") return end
        fxSlot = reaper.TrackFX_GetCount(selectedTrack)
        reaper.TrackFX_SetOpen(selectedTrack, fxSlot, true)
    end
end

addSpecifiedFXToSelectedTrack(arg[1])
-- return {addSpecifiedFXToSelectedTrack = addSpecifiedFXToSelectedTrack(chosenFX)}
