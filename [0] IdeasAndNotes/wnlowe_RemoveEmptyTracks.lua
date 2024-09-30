NumTracks = reaper.CountTracks( 0 )
for i=0,NumTracks do
   Track = reaper.GetTrack( 0, i )
   if reaper.CountTrackMediaItems( Track ) == 0 then
      reaper.DeleteTrack( Track )
   end
end