Ifdebug = true
function Msg(variable) if Ifdebug then reaper.ShowConsoleMsg(tostring(variable) .. "\n") end end

track = reaper.GetSelectedTrack(0, 0)
--Maybe Add Multilevel parent macro control? Feels clunky though.
    --[[
if reaper.TrackFX_GetByName( track, "MacroControl", false ) == -1 then
    if reaper.GetParentTrack( track ) == nil then
        paramIdx = reaper.TrackFX_AddByName( track, "MacroControl", false, -1 )
    
    else
        parentCount = 1
        parentTrack = {}
        parentTrack[0] = track
        parent = reaper.GetParentTrack( track )
        
        while parent ~= nil do
            parentTrack[parentCount] = parent
            parentCount = parentCount + 1
            parent = reaper.GetParentTrack( parent )
        end
        if parentCount > 1 then
            tracksString = ''
            for i = 0, #parentTrack do
                r, trackName = reaper.GetSetMediaTrackInfo_String( parentTrack[i], "P_NAME", "", false )
                tracksString = tracksString .. i .. " - " .. trackName .. "\n"
            end
            reaper.ShowMessageBox( "You have " .. tostring(parentCount) .. " parent tracks. They are: \n" .. tracksString .."\nIn the next dialog, insert the index of the track with a macro you want to connect to or add a macro control to.", "Select Parent Level", 0 )
            retval, parentIndex = reaper.GetUserInputs( "Select Parent Level", 1, "Parent Index:", "" )
        end
        
    end
end
]]

idx = reaper.TrackFX_GetByName(track, "MacroControl", true)

r, macro = reaper.GetUserInputs("Macro Index Connection", 1, "Macro Number:", "")
-- Msg(macro)
if not r then
    reaper.ReaScriptError( "!You did not select a macro" )
end
MacroSelect = "Macro"..macro

local  retval, tracknumber, fxnumber, paramnumber = reaper.GetLastTouchedFX()



parmname = 'param.' .. paramnumber .. '.plink.active'
local ret = reaper.TrackFX_SetNamedConfigParm( track, fxnumber, parmname, 1 )
parmname = 'param.' .. paramnumber .. '.plink.effect'
local ret1 = reaper.TrackFX_SetNamedConfigParm( track, fxnumber, parmname, idx )
paramname = 'param.' .. paramnumber .. 'plink.param'
local ret2 = reaper.TrackFX_SetNamedConfigParm(track, fxnumber, paramname, macro - 1)



-- retval, buf = reaper.TrackFX_GetNamedConfigParm( track, fxnumber, 'param.' .. paramnumber .. '.plink.param' )
-- -- retval, buf = reaper.TrackFX_GetNamedConfigParm( track, fxnumber, 'chain_pdc_actual' )

-- r, trackName = reaper.GetSetMediaTrackInfo_String( track, "P_NAME", "", false )
-- Msg(idx)
-- Msg(trackName)
-- Msg(fxnumber)
-- Msg(paramnumber)
-- Msg(tostring(retval) .. buf)