function Msg(variable)
    Dbug = false
    if Dbug then reaper.ShowConsoleMsg(tostring (variable).."\n") end
end

function FindItem()
    for i = 0, NumItems - 1 do
        if  reaper.GetMediaItem_Track( reaper.GetMediaItem(0, i) ) == Track then
            Msg("Step 1")
            curItem = reaper.GetMediaItem(0, i)
            startTime = reaper.GetMediaItemInfo_Value(curItem, "D_POSITION")
            endTime = startTime + reaper.GetMediaItemInfo_Value(curItem, "D_LENGTH")
            Msg(reaper.GetMediaItemInfo_Value(reaper.GetMediaItem(0, i), "D_LENGTH"))
            Msg(reaper.GetMediaItemInfo_Value(curItem, "D_LENGTH"))
            Msg(startTime .. " - " .. endTime)
            if CurTime >= startTime and CurTime <= endTime then
                Msg("Step 2")
                return reaper.GetMediaItem(0, i)
            end
        end
    end
    return nil
end


Track = reaper.GetSelectedTrack(0, 0)
CurTime =  reaper.GetCursorPosition()

Msg(CurTime)

NumItems =  reaper.CountMediaItems( 0 )
SelectItem = FindItem()
if SelectItem == nil then goto finish end

NumSelItems = reaper.CountSelectedMediaItems( 0 )
for j = 0, NumSelItems - 1 do
    reaper.SetMediaItemSelected( reaper.GetSelectedMediaItem( 0, j ), false )
end

reaper.SetMediaItemSelected( SelectItem, true )

::finish::