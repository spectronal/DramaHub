local BASE_URL = "https://raw.githubusercontent.com/spectronal/DramaHub/refs/heads/main/Games/World%20Fighters/"

local function import(path)
    return loadstring(game:HttpGet(BASE_URL .. path))()
end

local Click = import("systems/Click.lua")

Click.Attack()