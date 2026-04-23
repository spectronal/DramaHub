local BASE_URL = "https://raw.githubusercontent.com/spectronal/DramaHub/refs/heads/main/Games/World%20Fighters/"

local function import(path)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. path))()
    end)
    if not ok then
        warn("Erro ao importar", path, "->", result)
        return nil
    end
    return result
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Omni = require(ReplicatedStorage:WaitForChild("Omni"))

getgenv().Shared = { Omni = Omni }

local Click = import("Systems/Click.lua")

Click.Attack()