def addSpecifiedFXToSelectedTrack(chosenFX):
    numSelected = RPR_CountSelectedTracks(0)
    if  numSelected < 1 : return
    for i in range(numSelected):
        selectedTrack =  RPR_GetSelectedTrack(0, i)
        value =  RPR_TrackFX_AddByName( selectedTrack, chosenFX, false, -1 )
        if value == -1: 
            RPR_ShowConsoleMsg("there is an issue with this fx")
            return
        fxSlot = RPR_TrackFX_GetCount(selectedTrack)
        RPR_TrackFX_SetOpen( selectedTrack, fxSlot, True )
    
    return chosenFX


# def addSpecifiedFXToSelectedTrack():
    
#     if reaper.CountSelectedTracks() < 1 then return end
#     selectedTrack = reaper.GetSelectedTrack(0, 0)
#     value = reaper.TrackFX_AddByName( selectedTrack, chosenFX, false, -1 )
#     if value == -1 then reaper.ShowConsoleMsg("there is an issue with this fx")end
#     return

# addSpecifiedFXToSelectedTrack()