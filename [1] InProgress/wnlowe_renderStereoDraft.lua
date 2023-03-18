function Msg(variable)
    dbug = true
    if dbug then reaper.ShowConsoleMsg(tostring (param).."\n") end
end

dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
-- ultraschall.ApiTest()

pd = tostring(reaper.GetProjectPath())
projdir = string.sub(pd, 1, (string.len(pd) - 6))
renderdir = "E:/OneDrive - Facebook/AW2_zRenders"
wavSettings = ultraschall.CreateRenderCFG_WAV(2, 0, 3, 1, false )
vidSettings =  ultraschall.CreateRenderCFG_QTMOVMP4_Video(2, 100, 2, 1920, 1080, 30, true)
wavSettings32 = ultraschall.CreateRenderCFG_WAV(3, 0, 3, 1, false )
reaper.GetSetProjectInfo(0, "RENDER_BOUNDSFLAG", 1, true)

----------------------------------------
----------------------------------------
--UI
----------------------------------------
----------------------------------------
--UI Config
----------------------------------------
package.path = reaper.GetResourcePath() .. '/Scripts/rtk/1/?.lua'
local rtk = require('rtk')
local log = rtk.log
--Main Window
win = rtk.Window{w=640, h=480, halign = 'center', title='WNL Render Settings'}
--Vertical Primary Container
local main = win:add(rtk.VBox{halign="center", vspacing = 10})
----------------------------------------
--Mode Selection title and dropdown
----------------------------------------
local selectTitle = main:add(rtk.Text{"Select render type:", halign = "center"})
local selection = main:add(rtk.OptionMenu{
    menu={
        {'NVK Render', id='nvk', color = '#00FFFF'},
        {'Region Matrix', id='rrm'},
        {'Time Selection', id='time'},
    },
})
selection:attr('selected', 'nvk')
selection.onchange = function(self, item)
    method = item.id
end
----------------------------------------
--Close Count Settings
--note: add if docked check to remove this entirely
----------------------------------------
--Encompasing Horizontal box
local close = main:add(rtk.HBox{valign="center", hspacing = 20})
--Question Text
local ct = close:add(rtk.Text{"Close After?", halign = "center", valign = "center"})
--Checkbox
local cb = close:add(rtk.CheckBox{value = 'checked'})
cb.onchange = function(self)
    if cb.value == rtk.CheckBox.UNCHECKED then
        entry = close:add(rtk.Entry{placeholder='1', textwidth=15})
        entry.onkeypress = function(self, event)
            if event.keycode == rtk.keycodes.ESCAPE then
                self:clear()
                self:animate{'bg', dst=rtk.Attribute.DEFAULT}
            elseif event.keycode == rtk.keycodes.ENTER then
                self:animate{'bg', dst='lightgreen'}
            end
        end
    else
        close:remove_index(3)
    end
end
----------------------------------------
--Video Settings
----------------------------------------
local vv = main:add(rtk.VBox{halign='right', vspacing = 10})
local vid = vv:add(rtk.HBox{valign="center", hspacing = 20})
local vt = vid:add(rtk.Text{"Video?", halign = "center", valign = "center"})
local video = vid:add(rtk.CheckBox{value = 'unchecked'})
video.onchange = function(self)
    if video.value == rtk.CheckBox.CHECKED then
        local ah = vv:add(rtk.HBox{valign="center", hspacing = 20})
        local at = ah:add(rtk.Text{"Video as additional file?", halign = "center", valign = "center"})
        add = ah:add(rtk.CheckBox{value = 'unchecked'})
    else
        vv:remove_index(2)
    end
end
----------------------------------------
--Complete Button
----------------------------------------
local b = main:add(rtk.Button{label='Go'})
closeCount = 0
b.onclick = function()
    if method == "nvk" then nvk()
    elseif method == "rrm" then rrm()
    elseif method == "time" then time()
    end
    if cb.value == rtk.CheckBox.UNCHECKED then
        if tonumber(entry.value) ~= 0 then
            closeCount = closeCount + 1
            if closeCount >= tonumber(entry.value) then
                w:close()
            end
        end
    else w:close()
    end
end
win:open()
----------------------------------------
----------------------------------------
--Main Functions
----------------------------------------
----------------------------------------
function videoDraftRenderSettings()
    if video.value == rtk.CheckBox.CHECKED then
        if add.value == rtk.CheckBox.CHECKED then
            reaper.GetSetProjectInfo_String(0, "RENDER_FORMAT2", vidSettings, true)
        else reaper.GetSetProjectInfo_String(0, "RENDER_FORMAT", vidSettings, true)
            reaper.GetSetProjectInfo_String(0, "RENDER_FORMAT2", "", true)
        end
    elseif "wave" ~= reaper.GetSetProjectInfo_String(0, "RENDER_FORMAT", "", false) then
        reaper.GetSetProjectInfo_String(0, "RENDER_FORMAT", wavSettings, true)
        reaper.GetSetProjectInfo_String(0, "RENDER_FORMAT2", "", true)
    end
end

function nvk()
    reaper.GetSetProjectInfo(0, "RENDER_Channels", 2, true)
    reaper.GetSetProjectInfo(0, "RENDER_SETTINGS", 64, true)
    reaper.GetSetProjectInfo_String(0, "RENDER_FILE", projdir, true )
    reaper.GetSetProjectInfo_String(0, "RENDER_PATTERN", "$item", true)
    videoDraftRenderSettings()
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_RSfaa7657f9dc1372325043c3979f1f3997b109fb6"), 0)
    -- reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS3d1277b3748fad1eb32378430c16affef2a514b0"), 0)
end

function rrm()
    reaper.GetSetProjectInfo(0, "RENDER_Channels", 2, true)
    reaper.GetSetProjectInfo(0, "RENDER_SETTINGS", 8, true)
    reaper.GetSetProjectInfo_String(0, "RENDER_FILE", projdir, true )
    reaper.GetSetProjectInfo_String(0, "RENDER_PATTERN", "$region", true)
    videoDraftRenderSettings()
    reaper.Main_OnCommand(41823, 0)
    reaper.Main_OnCommand(41207, 0)
end

function time()
    reaper.GetSetProjectInfo(0, "RENDER_Channels", 2, true)
    reaper.GetSetProjectInfo(0, "RENDER_SETTINGS", 0, true)
    reaper.GetSetProjectInfo(0, "RENDER_BOUNDSFLAG", 2, true)
    reaper.GetSetProjectInfo_String(0, "RENDER_FILE", projdir, true )
    good, name = reaper.GetUserInputs("Filename", 1, "Filename (Wildcards valid): extrawidth=150", "")
    if good and name ~= "" then reaper.GetSetProjectInfo_String(0, "RENDER_PATTERN", name, true)
    else reaper.GetSetProjectInfo_String(0, "RENDER_PATTERN", "$project", true) end
    videoDraftRenderSettings()
    reaper.Main_OnCommand(41823, 0)
    reaper.Main_OnCommand(41207, 0)
    reaper.GetSetProjectInfo(0, "RENDER_BOUNDSFLAG", 1, true)
end