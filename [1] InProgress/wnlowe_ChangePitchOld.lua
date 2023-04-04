function Msg(variable)
    dbug = true
    if dbug then reaper.ShowConsoleMsg(tostring (variable).."\n") end
end

function MainFunction()
    item = reaper.GetSelectedMediaItem(0, 0)
    valid = reaper.CountSelectedMediaItems(0)
    -- if valid < 1 then reaper.defer(main) end
    take = reaper.GetActiveTake(item)
    currentModeNum = reaper.GetMediaItemTakeInfo_Value(take, "I_PITCHMODE")
    for a = 1, #allNums do
        b = allIdx[a]
        if allNums[b] == currentModeNum then
            activeMode = allNums[a][1]
            activeSubMode = allNums[a][2]
        end
    end
end

modes = {}
submodes = {}
allNums = {}
allIdx = {}
i = 0
n = 1
m = 1
while true do
    ok, modeName = reaper.EnumPitchShiftModes(i)
    if not ok then break end
    if modeName then
        modes[n] = {
            ["label"] = modeName,
            ["id"] = tostring(i)
        }
        n = n + 1
        j = 0
        sub = {}
        while true do
            subName = reaper.EnumPitchShiftSubModes(i, j)
            if not subName then break end
            sub[m] = {
                ["label"] = subName,
                ["id"] = tostring(j),
                ["ref"] = tostring(i)
            }
            idx = i<<16|j
            table.insert(allIdx, idx)
            allNums[idx] = {
                [modeName] = subName
            }
            -- table.insert(allNums, i<<16|j, )
            m = m + 1
            j = j + 1
        end
        if #sub > 0 then submodes[i] = sub end
        Msg(#sub)
    end
    i = i + 1
end

package.path = reaper.GetResourcePath() .. '/Scripts/rtk/1/?.lua'
local rtk = require('rtk')
local log = rtk.log
--Main Window
win = rtk.Window{w=640, h=480, halign = 'center', title='WNL Change Pitch Algorithm'}
--Vertical Primary Container
local main = win:add(rtk.VBox{halign="center", vspacing = 10})
local modeSelect = main:add(rtk.OptionMenu{
    menu = modes
})
selected = 0
win:open()
-- reaper.defer(main)
MainFunction()


-- reaper.ShowConsoleMsg(test .."\n")
-- r, mode = reaper.EnumPitchShiftModes(test)
-- reaper.ShowConsoleMsg(mode .. "\n")

--[[
local list, n = {}, 1
local i = 0
while true do
	local ok, mode_name = reaper.EnumPitchShiftModes(i)
	if not ok then break end -- exit loop
	if mode_name then
		list[n] = string.format("%d: %s\n", i, mode_name); n=n+1 -- mode
		local j = 0
		while true do
			local submode_name = reaper.EnumPitchShiftSubModes(i, j)
			if not submode_name then break end -- exit loop
			list[n] = string.format("    %d: %s\n", j, submode_name); n=n+1 -- submode
			j=j+1
		end
	end
	i=i+1
end]]

--[[
local mode = 9 -- élastique 3.3.3 Pro
local submode = 16 -- Synchronized: Normal

local item_count = reaper.CountSelectedMediaItems(0); if item_count == 0 then return end -- exit
local takes, n = {}, 1
for i = 0 , item_count - 1 do
	local item = reaper.GetSelectedMediaItem(0, i)
	local take = reaper.GetActiveTake(item)
	if take then takes[n] = take; n=n+1 end
end

if n == 1 then return end -- exit

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
	for i, take in ipairs(takes) do
		reaper.SetMediaItemTakeInfo_Value(take, "I_PITCHMODE", mode<<16|submode)
	end
reaper.Undo_EndBlock("Set pitch shift mode", -1)
reaper.PreventUIRefresh(-
]]