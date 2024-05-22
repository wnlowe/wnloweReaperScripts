-- Add Regions in your time selection from the selected track to your Region Render Matrix
-- By William N. Lowe
-- wnlsounddesign.com

function Msg(variable)
    Dbug = false
    if Dbug then reaper.ShowConsoleMsg(tostring (variable).."\n") end
end

retval, UsrMode = reaper.GetUserInputs( "Mode", 1, "Script Mode: ", "")
UsrMode = tonumber(UsrMode)

function SelectTrack(selection)
    local selectedTrack = reaper.GetSelectedTrack(0, 0)
    local re, trackName = reaper.GetSetMediaTrackInfo_String( selectedTrack, "P_NAME", "", false )
    if UsrMode == 0 then
        if string.find(trackName, "SFX_") == nil then
            return  reaper.GetParentTrack( selectedTrack )
        else
            return selectedTrack
        end
    elseif UsrMode == 1 then
        return TrackSel[AddRegions[selection]]
    end
    
end

StartTime, EndTime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
ret, marks, regs = reaper.CountProjectMarkers(0)

AddRegions = {}
TrackRegions = {}
TrackSel = {}
for i = 0, regs + marks do
    ret, isr, regPos, regEnd, regName, MarInx = reaper.EnumProjectMarkers(i)
    if isr and regPos > StartTime and regPos < EndTime then
        numItems = reaper.CountMediaItems( 0 )
        for j = 0, numItems - 1 do
            item =  reaper.GetMediaItem( 0, j )
            if reaper.GetMediaItemInfo_Value(item, "D_POSITION") == regPos then
                local trk = reaper.GetMediaItemInfo_Value(item, "P_TRACK")
                local re, sNB = reaper.GetSetMediaTrackInfo_String( trk, "P_NAME", "", false )
                if string.find(sNB, "SFX_") == nil then
                    goto continue
                end
            end
        end
        Msg("NOT FOUND")
        goto notFound
        ::continue::
        take = reaper.GetActiveTake(item)
        raw = reaper.GetMediaItemTake_Source( take )
        chan = reaper.GetMediaSourceNumChannels( raw )
        Msg(chan)
        table.insert(AddRegions, MarInx)
        TrackRegions[MarInx] = chan * 2
        TrackSel[MarInx] =  reaper.GetMediaItemTrack( item )
        ::notFound::
    end
end



for ri = 1, #AddRegions do
    -- Msg(TrackRegions[AddRegions[ri]])
    reaper.SetRegionRenderMatrix(0, AddRegions[ri],
                                 SelectTrack(ri), TrackRegions[AddRegions[ri]])
end
reaper.DockWindowRefresh()
