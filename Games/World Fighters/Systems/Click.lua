local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Omni = require(ReplicatedStorage.Omni)

local Click = {}

function Click.Attack()
    print("Click.Attack chamado")
    local ok, err = pcall(function()
        Omni.Signal:Fire("General", "Attack", "Click")
    end)
    print("ok:", ok, "err:", err)
end

return Click
