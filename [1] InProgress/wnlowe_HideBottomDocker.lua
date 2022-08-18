--local retval, reaper.BR_Win32_GetMixerHwnd()
--DockID = reaper.ImGui_GetWindowDockID(context)

Clean = true
DockerCount = 0
WindowIDs = {"Video", "Mixer", "Track Manager", "Region/Marker Manager", "Region Render Matrix", "Virtual MIDI Keyboard", "Media Explorer"}
while Clean do
    DockPosition = reaper.DockGetPosition(DockerCount)
    if DockPosition == -1 then break else if DockPosition == 0 then BottomDocker = DockerCount end end 
end

DockIDs = {}
ValidWindows = {}

for i = 1, #WindowIDs do
    DockID = reaper.GetConfigWantsDock(WindowIDs[i])
    if DockID == BottomDocker then ValidWindows.newKey = WindowIDs[i] end
end

