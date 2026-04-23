local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Omni = require(ReplicatedStorage:WaitForChild("Omni"))

Omni.Signal:Fire("General", "Attack", "Click")



local BASE_URL = "https://raw.githubusercontent.com/seu-user/dramahub/main/"

local function import(path)
    return loadstring(game:HttpGet(BASE_URL .. path))()
end

local Utils = import("functions/utils.lua")
local UI = import("ui/components.lua")