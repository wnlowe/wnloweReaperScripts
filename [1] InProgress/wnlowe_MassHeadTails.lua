numItems = reaper.CountSelectedMediaItems(0)
allItems = {}
for i = 0, numItems do
    allItems[i] = reaper.GetSelectedMediaItem(0, i)
end

reaper.Main_OnCommand(40289, 0)

for j = 0, numItems do
    reaper.SetMediaItemSelected( allItems[j], true )
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS9e12f1aa39697d84844c05ba90a19c5748408600", 0))
    reaper.SetMediaItemSelected( allItems[j], false )
end