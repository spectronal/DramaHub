getgenv().Player = {}
local Shared = getgenv().Shared
local Omni = Shared.Omni

local Player = getgenv().Player

function Player:Attack()
    Omni.Signal:Fire("General", "Attack", "Click", {})
end

function Player:Awakening()
    Omni.Signal:Fire("General", "Awakening", "Click", {})
end
