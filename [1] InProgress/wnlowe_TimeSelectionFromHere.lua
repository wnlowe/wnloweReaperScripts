retval, inputInfo = reaper.GetUserInputs( "Selection Length", 1, "Selection Time: ", "" )
colonCheck, ce = string.find(inputInfo, ":")
Length  = 0
if colonCheck ~= nil then
    minute = string.sub(inputInfo, 1, colonCheck - 1)
    second = string.sub(inputInfo, colonCheck + 1, -1)
    Length = tonumber(minute) * 60 + tonumber(second)
else
    Length = tonumber(inputInfo)
end

startLocation =  reaper.GetCursorPosition()
loopStart, loopEnd = reaper.GetSet_LoopTimeRange( true, false, startLocation, startLocation + Length, true )