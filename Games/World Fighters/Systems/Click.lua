local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Omni = require(ReplicatedStorage:WaitForChild("Omni"))

getgenv().System = getgenv().System or {}
getgenv().System.Click = {}

local Click = getgenv().System.Click

function Click.Attack()
    Omni.Signal:Fire("General", "Attack", "Click")
end

return Click