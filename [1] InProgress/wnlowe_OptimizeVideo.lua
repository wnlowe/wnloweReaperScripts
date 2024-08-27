Ifdebug = true
function Msg(variable) if Ifdebug then reaper.ShowConsoleMsg(tostring(variable) .. "\n") end end
ResourcePath = reaper.GetResourcePath() .. "/Scripts/"

function FileExists(file)
    local ok, err, code = os.rename(file,file)
    if not ok then if code == 13 then return true end end
    return ok
end

if reaper.CountSelectedMediaItems(0) < 1 then

else
    r, OutputFilename = reaper.GetUserInputs( "New Filename", 1, "Name of Output File", "")
    if OutputFilename == "" then OutputFilename = "OutputFile.mov"
end
Item = reaper.GetSelectedMediaItem(0, 0)
Take = reaper.GetActiveTake(Item)
SourceID = reaper.GetMediaItemTake_Source( Take )
SourcePath = reaper.GetMediaSourceFileName( SourceID )

BatchFilename = "WNL_OptimizeVideo.bat"
BatchFilepath = ResourcePath..BatchFilename

if FileExists(BatchFilepath) then
    os.execute(BatchFilepath SourcePath DestinationPath)
else
    BatchContents = "echo off\nset arg1=%1\nset arg2=%2\nshift\nshit\nffmpeg -i %arg1% -c:v prores_ks -c:a pcm_s24le %arg2%"
    
    local file = assert(io.open(bat, "w"))
    file:write(BatchContents)
    file:close()

    os.execute(BatchFilepath SourcePath DestinationPath)
end

-- reaper.SetMediaItemTake_Source( take, source )