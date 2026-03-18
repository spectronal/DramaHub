-- Core/Farm.lua
-- Auto Farm Mobs (Gamemode enemies)
-- Loaded via: loadstring(game:HttpGet(URL))()

getgenv().DH = getgenv().DH or {}
getgenv().DH.Farm = {}

local Farm = getgenv().DH.Farm
local State = getgenv().DH.State

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Framework = State.Framework

-- ════════════════════════════════════════
-- Helpers
-- ════════════════════════════════════════

local function isFarFromMob(mob)
	if not mob then
		return false
	end
	return (State.PlayerRootPart.Position - mob.Position).Magnitude > 8
end

local function teleportToMob(mob)
	if not mob then
		return
	end

	if tick() - State.lastTeleport >= State.teleportCooldown then
		if isFarFromMob(mob) then
			local height = Vector3.new(0, 6, 0)
			State.PlayerRootPart.CFrame = CFrame.new(mob.Position + height)
			State.lastTeleport = tick()
		end
	end
end

local function getNextMob()
	local mobsList = {}
	local Gamemode = getgenv().DH.Gamemode

	for _, mob in pairs(State.enemiesFolder:WaitForChild("Gamemode"):GetDescendants()) do
		if
			mob:IsA("Part")
			and mob.Parent
			and mob.Parent.Name == Gamemode.getPlayerMode("Mode")
			and mob:GetAttribute("Order")
		then
			table.insert(mobsList, mob)
		end
	end

	for _, warriors in pairs(workspace["_WARRIORS"]:GetDescendants()) do
		if warriors:IsA("Model") and warriors.Parent:IsA("Folder") then
			local warriorRootPart = warriors.HumanoidRootPart
			warriorRootPart.Position = Vector3.new(workspace["_CHARACTERS"][LocalPlayer.Name].HumanoidRootPart.Position)
		end
	end

	table.sort(mobsList, function(a, b)
		return a:GetAttribute("Order") < b:GetAttribute("Order")
	end)

	return mobsList[1]
end

-- ════════════════════════════════════════
-- Auto Farm
-- ════════════════════════════════════════

function Farm.autoFarmEnemies()
	if not State.currentMob or not State.currentMob.Parent then
		State.currentMob = getNextMob()
		State.lastHP = nil
		State.stuckTime = 0

		if State.currentMob then
			teleportToMob(State.currentMob)
		else
			return
		end
	end

	Framework.Remote:Fire("ClickSystem", "Execute", Framework.Target)
	teleportToMob(State.currentMob)

	local currentHP = State.currentMob:GetAttribute("HP")

	if State.lastHP then
		if currentHP == State.lastHP then
			State.stuckTime += 1
		else
			State.stuckTime = 0
		end

		if State.stuckTime >= 5 then
			teleportToMob(State.currentMob)
			State.stuckTime = 0
		end
	end

	State.lastHP = currentHP
end
