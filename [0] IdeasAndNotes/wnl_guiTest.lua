function Msg(variable)
    reaper.ShowConsoleMsg(tostring(variable).."\n")
end

-- Set package path to find rtk installed via ReaPack
package.path = reaper.GetResourcePath() .. '/Scripts/rtk/1/?.lua'
local rtk = require('rtk')
local log = rtk.log
local w = rtk.Window{w=640, h=480}
local main = w:add(rtk.VBox{halign="center", vspacing = 10})
local dropsContainer = main:add(rtk.FlowBox{vspacing=10, hspacing=10})
for i = 1, 6 do
    local contain = dropsContainer:add(rtk.VBox{halign = "center"})
    local label = contain:add(rtk.Text{"Box "..i..":", halign = "center"})
    local sevarity = contain:add(rtk.OptionMenu{
        menu={
            {'Good', id='#00FFFF'},
            {'Bad', id='#FF0000'},
            {'Warning', id='#FFFF00'},
            {'Purple', id='purple'},
        },
    })

    sevarity.onchange = function(self, item)
        Msg(self)
        self:attr('color', item.id)
    end

    sevarity:attr('selected', 'purple')
end

local b = rtk.Button{label='Hello world', iconpos='right'}
b.onclick = function()
   -- Toggles between a circle and rectangular button when clicked.
   for j = 1, 6 do
    cont = box:get_child(j)
    Msg(cont:get_child(2).label)
   end
end
main:add(b)

w:open()