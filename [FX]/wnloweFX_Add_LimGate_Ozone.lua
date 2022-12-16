chosenFX = "VST3:Ozone 10 Vintage Limiter"

local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]

local subsystem = assert(loadfile(script_path .. "wnloweFX_AddFunction.lua"))(chosenFX)
