Item = reaper.GetSelectedMediaItem(0, 0)
Take = reaper.GetActiveTake(Item)
Source = reaper.GetMediaItemTake_Source( Take )


reaper.SetMediaItemTake_Source( take, source )