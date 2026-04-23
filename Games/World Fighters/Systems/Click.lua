local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Omni = require(ReplicatedStorage:WaitForChild("Omni"))

local Click = {}

function Click.Attack()
    Omni.Signal:Fire("General", "Attack", "Click")
end

return Click