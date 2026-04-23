getgenv().Click = {}
local Shared = getgenv().Shared
local Omni = Shared.Omni

local Click = getgenv().Click

function Click.Attack()
    Omni.Signal:Fire("General", "Attack", "Click", {})
end
