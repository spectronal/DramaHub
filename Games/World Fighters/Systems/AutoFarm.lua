local ReplicatedStorage = game:GetService("ReplicatedStorage")
getgenv().AutoFarm = {}
local AutoFarm = getgenv().AutoFarm
local Shared = getgenv().Shared
local Player = getgenv().Player
local Settings = getgenv().Settings

local Utils = Shared.Utils
local FarmConfig = Shared.FarmConfig
local Omni = Shared.Omni
local ReplicatedStorage = Shared.Services.ReplicatedStorage

local Priorities = {
    ["Boss"] = 1,
    ["Insane"] = 2,
    ["Hard"] = 3,
    ["Medium"] = 4,
    ["Easy"] = 5,
}

local function isFarFromMob(mob)
	if not mob then
		return false
	end
	return (Utils.HumanoidRootPart.Position - mob.Position).Magnitude > 8
end

local function teleportToMob(mob)
	if not mob then
		return
	end

	if tick() - FarmConfig.lastTeleport >= FarmConfig.teleportCooldown then
		if isFarFromMob(mob) then
			local height = Vector3.new(0, 6, 0)
			Utils.HumanoidRootPart.CFrame = CFrame.new(mob.Position + height)
			FarmConfig.lastTeleport = tick()
		end
	end
end

local function getNextMob(from: "Gamemode" | "Game")
    local mobList = {}

    if from == "Game" then
        for _, mob in pairs(workspace.Server.Enemies.World:GetDescendants()) do
            if mob:IsA("Part") and mob.Name ~= "Test Dummy" and mob.Parent.Parent.Name == Omni.Data.Map then
                if Settings.Farm.SelectedEnemy[mob.Name] == true then
                    table.insert(mobList, mob)
                end
            end
        end

        table.sort(mobList, function(a, b)
            if Settings.Farm.Priority == "Strongest > Weakest" then
                return a:GetAttribute("Health") > b:GetAttribute("Health")
            else
                return a:GetAttribute("Health") < b:GetAttribute("Health")
            end
        end)

        print(mobList[1])

        return mobList[1]
    elseif from == "Gamemode" then
        local mobListGamemode = {}
        
        for _, mob in pairs(workspace.Server.Enemies.Gamemodes:GetDescendants()) do 
            if mob:IsA("Part") and mob.Name ~= "Test Dummy" and mob.Parent.Name == Omni.Data.Map then
                table.insert(mobListGamemode, mob)
            end
        end

        table.sort(mobListGamemode, function(a, b)
            if Settings.Farm.Priority == "Strongest > Weakest" then
                return a:GetAttribute("Health") > b:GetAttribute("Health")
            else
                return a:GetAttribute("Health") < b:GetAttribute("Health")
            end
        end)

        print(mobListGamemode[1])

        return mobListGamemode[1]
    end

    return
end

local function isInGamemode() 
    local gamemodeMaps = {}
    for _, maps in pairs(ReplicatedStorage.Omni.Shared.Gamemodes:GetChildren()) do
        table.insert(gamemodeMaps, maps)
    end

    if Omni.Data.Map then
        for _, map in pairs(gamemodeMaps) do
            if Omni.Data.Map == map then
                return true
            end
        end
    end
    return false
end

function AutoFarm:FarmMob()
    if isInGamemode() then return end

    if not FarmConfig.currentMobNormal or not FarmConfig.currentMobNormal:GetAttribute("Died") or not FarmConfig.currentMobNormal.Parent or FarmConfig.currentMobNormal.Parent.Parent.Name ~= Omni.Data.Map then
        FarmConfig.currentMobNormal = getNextMob("Game")

        FarmConfig.lastHP = nil
        FarmConfig.stuckTime = 0

        if FarmConfig.currentMobNormal then
            teleportToMob(FarmConfig.currentMobNormal)
        else
            return
        end
    end

    local enemies = Omni.Cache:Get({ "EnemiesOnRangeIds" }) or {}
    Omni.Signal:Fire("General", "Attack", "Click", enemies)

    local currentHP = FarmConfig.currentMobNormal:GetAttribute("Health")

    if FarmConfig.lastHP then
        if currentHP == FarmConfig.lastHP then
            FarmConfig.stuckTime += 1
        else
            FarmConfig.stuckTime = 0
        end

        if FarmConfig.stuckTime >= 5 then
            teleportToMob(FarmConfig.currentMobNormal)
            FarmConfig.stuckTime = 0
        end
    end
    
    FarmConfig.lastHP = currentHP
end