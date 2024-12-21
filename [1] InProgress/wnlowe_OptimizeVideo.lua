--Print Function
Ifdebug = false
function Msg(variable) if Ifdebug then reaper.ShowConsoleMsg(tostring(variable) .. "\n") end end

--Adapt to OS
ComputerOS = reaper.GetOS()
if string.find(ComputerOS, "Win") ~= nil then Slash = "\\"
elseif string.find(ComputerOS, "OS") ~= nil then Slash = "/" end

--Find Paths
ProjectPath = reaper.GetProjectPath() .. Slash
ResourcePath = reaper.GetResourcePath() .. Slash .."Scripts" .. Slash

--Helper Functions
function FileExists(file)
    local ok, err, code = os.rename(file,file)
    if not ok then if code == 13 then return true end end
    return ok
end

--Ensure valid selection and get destination filename
if reaper.CountSelectedMediaItems(0) < 1 then
    goto faliure
else
    r, OutputFilename = reaper.GetUserInputs( "New Filename", 1, "Name of Output File", "")
    if r and OutputFilename == "" then OutputFilename = "OutputFile.mov" elseif not r then goto faliure
    elseif string.find(OutputFilename, ".mov") == nil then
        if string.find(OutputFilename, ".mp4") ~= nil then
            OutputFilename:gsub(".mp4", ".mov")
        elseif string.find(OutputFilename, ".wmv") ~= nil then
            OutputFilename:gsub(".wmv", ".mov")
        else
            OutputFilename = OutputFilename .. ".mov"
        end
    end
end
Msg(OutputFilename)

--Basic vartiables
Item = reaper.GetSelectedMediaItem(0, 0)
Take = reaper.GetActiveTake(Item)
SourceID = reaper.GetMediaItemTake_Source( Take )
SourcePath = reaper.GetMediaSourceFileName( SourceID )

--specific paths
BatchFilename = "WNL_OptimizeVideo.bat"
BatchFilepath = ResourcePath..BatchFilename
DestinationPath = ProjectPath..OutputFilename

--bat file actions
UR = reaper.MB("FYI: Reaper is about to freeze for the length of the video conversion. \n\nIs this okay?", "Long Hold Incoming", 1)
if UR == 2 then goto faliure elseif UR ~= 1 then goto faliure end

os.execute("ffmpeg -i \"" .. SourcePath .."\" -c:v prores_ks -c:a pcm_s24le \"" .. DestinationPath .."\"")

UR2 = reaper.MB("Process Complete! Would you like to replace the original file in REAPER? \n(This will not remove the original from your computer)\n\nYES: Replace the take\nNO: Add a new active take and place the converted video there (Might take a second)\nCANCEL: Do not change takes at all","Conversion Complete", 3)

if UR2 == 6 then
    -- reaper.SetMediaItemTake_Source( Take, reaper.PCM_Source_CreateFromFile( DestinationPath ) )
    r = reaper.BR_SetTakeSourceFromFile2( Take, DestinationPath, false, true )
    rz, TakeName = reaper.GetSetMediaItemTakeInfo_String( Take, "P_NAME", "", false )
    if string.find(SourcePath, TakeName) ~= nil then
        local retval, stringNeedBig = reaper.GetSetMediaItemTakeInfo_String( Take, "P_NAME", OutputFilename, true )
    end
elseif UR2 == 7 then
    -- NewTake = reaper.AddTakeToMediaItem( Item )
    -- reaper.SetMediaItemTake_Source( NewTake,  reaper.PCM_Source_CreateFromFile( DestinationPath )  )
    r = reaper.InsertMedia( DestinationPath, 3 )
    -- reaper.SetActiveTake( NewTake )
elseif UR2 == 2 then goto faliure
else goto faliure
end
Msg("Done")

::faliure::