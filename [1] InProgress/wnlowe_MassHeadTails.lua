-- use this https://forum.cockos.com/showthread.php?t=234366 to get a prompt for user input to mass complete any action

------U S E R  S P E C I F I C ---------
headTailsCommand = "_RS9e12f1aa39697d84844c05ba90a19c5748408600"
--######################################

reaper.Undo_BeginBlock()

numItems = reaper.CountSelectedMediaItems(0)
allItems = {}
for i = 0, numItems do
    allItems[i] = reaper.GetSelectedMediaItem(0, i)
end

reaper.Main_OnCommand(40289, 0)

for j = 0, #allItems do
    reaper.SetMediaItemSelected( allItems[j], true )
    commandId = reaper.NamedCommandLookup(headTailsCommand)
    reaper.Main_OnCommand(commandId, 0)
    reaper.SetMediaItemSelected( allItems[j], false )
end

for i = 0, #allItems do
    reaper.SetMediaItemSelected( allItems[i], true )
end

reaper.Undo_EndBlock("Mass Deployment of Heads and Tails script by WNL & RL")