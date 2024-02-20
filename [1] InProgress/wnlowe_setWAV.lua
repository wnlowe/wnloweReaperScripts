dbug = false
function Msg(variable)
    if dbug then reaper.ShowConsoleMsg(tostring (variable).."\n") end
end

--UltraSchall API Enable
dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
if dbug then ultraschall.ApiTest() end

wavSettings = ultraschall.CreateRenderCFG_WAV(2, 0, 3, 1, false )
reaper.GetSetProjectInfo(0, "RENDER_SETTINGS", 64, true)
reaper.GetSetProjectInfo_String(0, "RENDER_FORMAT", wavSettings, true)

reaper.Main_OnCommand(reaper.NamedCommandLookup("_RSfaa7657f9dc1372325043c3979f1f3997b109fb6"), 0)