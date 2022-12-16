chosenFX = "VST:Shadow Hills Mastering Compressor"

local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]

local subsystem = assert(loadfile(script_path .. "wnloweFX_AddFunction.lua"))(chosenFX)
