local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Omni = require(ReplicatedStorage:WaitForChild("Omni"))

local Click = {}

function Click.Attack()
    print("Click.Attack chamado")
    local ok, err = pcall(function()
        Omni.Signal:Fire("General", "Attack", "Click")
    end)
    if not ok then
        warn("Erro no Fire:", err)
    end
end

return Click
