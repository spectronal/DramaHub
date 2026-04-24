getgenv().Utils = {} 

local Utils = getgenv().Utils
local Shared = getgenv().Shared

function Utils.GetEnemies(Types: "Clear" | "Game") 
    local Inserted = Shared.FarmConfig.Inserted
    local Enemies = Shared.FarmConfig.Enemies

    local EnemiesFolder = workspace:WaitForChild("Server"):WaitForChild("Enemies")

    if Types == "Game" then
        for _, world in pairs(EnemiesFolder.World:GetDescendants()) do
            for _, enemy in pairs(world:GetDescendants()) do
                if enemy:IsA("Part") and not table.find(Inserted, enemy.Name) then
                    table.insert(Inserted, enemy.Name)
                    table.insert(Enemies, enemy.Name)
                end
            end
        end
     elseif Types == "Clear" then
        table.clear(Inserted)
        table.clear(Enemies)
     end

    return Enemies
end