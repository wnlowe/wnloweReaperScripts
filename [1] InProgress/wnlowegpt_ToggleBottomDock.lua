-- get the main window
local main_window = reaper.JS_Window_FindTop()

-- get the bottom dock
local bottom_dock = reaper.JS_Window_FindChildByID(main_window, 1017)

-- get the list of windows in the bottom dock
local window_list = reaper.JS_Window_ListAllChild(bottom_dock)

-- iterate over the list of windows
for i, window in ipairs(window_list) do
  
  -- show or hide the window based on its current visibility
  if reaper.JS_Window_IsVisible(window) then
    reaper.JS_Window_Hide(window)
  else
    reaper.JS_Window_Show(window)
  end
end 