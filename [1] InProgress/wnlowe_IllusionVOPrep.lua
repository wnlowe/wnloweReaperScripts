----------------------------------------------------------
----------------------------------------------------------
--HELPERS
----------------------------------------------------------
----------------------------------------------------------
function Msg(variable)
    dbug = false
    if dbug then reaper.ShowConsoleMsg(tostring (variable).."\n") end
end

function mysplit(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    local i = 0
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      t[i] = str
      i = i+1
    end
    return t
end

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()

Path = reaper.GetProjectPath()
Folders = {}
Folders = mysplit(Path, "\\")

TargetDirectory = Folders[0] .. "\\" .. Folders[1] .. "\\" .. Folders[2] .. "\\" .. Folders[3] .. "\\" .. Folders[4] .. "\\" .. "Export" .. "\\" .. Folders[5]

retval, valuestrNeedBig = reaper.GetSetProjectInfo_String( 0, "RENDER_FILE", TargetDirectory, true )
retval, valuestrNeedBig = reaper.GetSetProjectInfo_String( 0, "RECORD_PATH", "00000000", true )
reaper.GetSetProjectInfo( 0, "RENDER_TAILFLAG", 0, true )

retval, isrgn, pos, rgnend, name, markrgnindexnumber, BadColor = reaper.EnumProjectMarkers3( 0, 1 )
retval, num_markers, num_regions = reaper.CountProjectMarkers( 0 )

for i = 0, num_regions do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3( 0, i )
    if color == BadColor then
        reaper.DeleteProjectMarker( 0, i, true )
    end
end

reaper.InsertTrackAtIndex( 0, false )
ParentTrack = reaper.GetTrack( 0, 0 )
reaper.SetMediaTrackInfo_Value( ParentTrack, "I_FOLDERDEPTH", 1 )
reaper.GetSetMediaTrackInfo_String(ParentTrack, "P_NAME ", "Monitor", true)

reaper.TrackFX_AddByName(ParentTrack, "[ILL] VO MON.rfxchain", false, -1)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_WNCLS3"), 0) -- SWS/S&M: Close all floating FX windows

reaper.TrackFX_AddByName(reaper.GetTrack(0, 1), "[ILL] VO BASE.rfxchain", false, -1)

reaper.TrackFX_SetOpen( reaper.GetTrack(0, 1), 3, false )
reaper.TrackFX_SetOpen( reaper.GetTrack(0, 0), 0, true )

-- local height = reaper.GetMediaTrackInfo_Value(reaper.GetTrack(0, 0), "I_TCPH ")
-- reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0, 0), "I_HEIGHTOVERRIDE", height - 1)
-- reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0, 0), "B_HeightLock", true)

-- local height = reaper.GetMediaTrackInfo_Value(reaper.GetTrack(1, 0), "I_TCPH ")
-- reaper.SetMediaTrackInfo_Value(reaper.GetTrack(1, 0), "I_HEIGHTOVERRIDE", height - 1)
-- reaper.SetMediaTrackInfo_Value(reaper.GetTrack(1, 0), "B_HeightLock", true)

reaper.Main_OnCommand(1157, 0) -- Options: Toggle snapping
local zstart, zend = reaper.GetSet_LoopTimeRange( true, false, 0, 0, true )

reaper.Undo_EndBlock("Project Illusion VO Session Setup", 0)
reaper.PreventUIRefresh(1)