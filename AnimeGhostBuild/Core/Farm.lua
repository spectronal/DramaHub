getgenv().DH = getgenv().DH or {}
getgenv().DH.Farm = {}

local Farm = getgenv().DH.Farm
local State = getgenv().DH.State
local Gamemode = getgenv().DH.Gamemode

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Framework = State.Framework

-- Helpers

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

local function getNextMob(from: "Gamemode" | "Game")
	local mobsList = {}

	if from == "Gamemode" then
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

		table.sort(mobsList, function(a, b)
			return a:GetAttribute("Order") < b:GetAttribute("Order")
		end)

		return mobsList[1]
	elseif from == "Game" then
		local validMobs = {}

		for _, mob in pairs(State.enemiesFolder:GetDescendants()) do
			if mob:IsA("Part") and mob:GetAttribute("HP") and mob:GetAttribute("Order") then
				for _, mobClient in pairs(State.enemiesClientFolder:GetDescendants()) do
					if mobClient:IsA("Model") and mob.Name == mobClient.Name then
						if State.scriptSettings.FarmTab.SelectMobs[mob:GetAttribute("Name")] == true then
							table.insert(validMobs, mob)
						end
					end
				end
			end
		end

		table.sort(validMobs, function(a, b)
			return a:GetAttribute("Order") < b:GetAttribute("Order")
		end)

		return validMobs[1]
	end

	return
end

-- Auto Farm

function Farm.autoFarmEnemies(typemode: "Gamemode" | "Game")
	if not State.currentMob or not State.currentMob.Parent or State.currentMob:GetAttribute("Dead") == true then
		if typemode == "Gamemode" then
			State.currentMob = ""
			State.currentMob = getNextMob("Gamemode")
		elseif typemode == "Game" then
			if not game.Players.LocalPlayer:GetAttribute("InMode") then
				State.currentMob = ""
				State.currentMob = getNextMob("Game")
			end
		end

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
