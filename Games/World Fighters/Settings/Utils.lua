getgenv().Utils = {} 

local Utils = getgenv().Utils
local Shared = getgenv().Shared

function Utils.GetEnemies(Types: "Clear" | "Game") 
    local Inserted = Shared.FarmConfig.Inserted

    local EnemiesFolder = workspace:WaitForChild("Server"):WaitForChild("Enemies")
    local Enemies = {}

    if Types == "Game" then
        for _, world in pairs(EnemiesFolder.World:GetDescendants()) do
            for _, enemy in pairs(world:GetDescendants()) do
                if enemy:IsA("Part") and not table.find(Inserted, enemy) then
                    table.insert(Inserted, tostring(enemy))
                    table.insert(Enemies, tostring(enemy))
                end
            end
        end
     elseif Types == "Clear" then
        table.clear(Inserted)
        table.clear(Enemies)
     end

    return Enemies
end