reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
DeleteBucket = {}
BucketIndex = 0


NumTracks = reaper.CountTracks( 0 )
for i=0,NumTracks do
   Track = reaper.GetTrack( 0, i )
   if Track ~= nil then
      if reaper.CountTrackMediaItems( Track ) == 0 then
         DeleteBucket[BucketIndex] = Track
         BucketIndex = BucketIndex + 1
      end
   end
end

for j = 0, BucketIndex - 1 do
   reaper.DeleteTrack( DeleteBucket[j] )
end

reaper.Undo_EndBlock( "wnlowe - Remove all tracks without media items", 0 )
reaper.PreventUIRefresh(-1)