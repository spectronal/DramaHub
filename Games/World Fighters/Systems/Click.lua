local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Omni = require(ReplicatedStorage:WaitForChild("Omni"))
print(Omni.Signal)
print(Omni.Signal.Fire)

local Click = {}

function Click.Attack()
    print("Click.Attack chamado")
    task.spawn(function()
        local ok, err = pcall(function()
            Omni.Signal:Fire("General", "Attack", "Click", {})
        end)
        print("ok:", ok, "err:", err)
    end)
end

return Click
