dbug = false
function Msg(variable)
    if dbug then reaper.ShowConsoleMsg(tostring (variable).."\n") end
end

--UltraSchall API Enable
dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
if dbug then ultraschall.ApiTest() end

vidSettings =  ultraschall.CreateRenderCFG_QTMOVMP4_Video(2, 100, 2, 1920, 1080, 30, true)
reaper.GetSetProjectInfo(0, "RENDER_SETTINGS", 32, true)
reaper.GetSetProjectInfo_String(0, "RENDER_FORMAT", vidSettings, true)

reaper.Main_OnCommand(reaper.NamedCommandLookup("_RSfaa7657f9dc1372325043c3979f1f3997b109fb6"), 0)