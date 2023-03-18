function Msg(variable) reaper.ShowConsoleMsg(tostring(variable) .. "\n") end

pointValue = 0.15

trackParam = reaper.GetTrackEnvelopeByName(  reaper.GetSelectedTrack(0, 0), "Delay (ms) / Delay" )
if trackParam ~= nill then 
    Msg("Success")
end


reaper.InsertEnvelopePoint( trackParam, 0, pointValue, 1, 0, 1 )
--[[
reaper.GetTrackEnvelopeByName( track, envname )

reaper.SetEnvelopePoint( envelope, ptidx, timeIn, valueIn, shapeIn, tensionIn, selectedIn, noSortIn )

]]
