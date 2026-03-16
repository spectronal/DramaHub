local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Framework = require(replicatedStorage.Framework.Library)
local Abbreviate = Framework:GetService("AbbreviateService")
local MultiplierService = Framework:GetService("MultiplierService")
local DebounceService = Framework:GetService("DebounceService")
local AnimationService = Framework:GetService("AnimationService")

local GamemodeData = Framework:GetData("GamemodeData")

-- Gamemodes
local PlayersInGamemodes = {}
local Gamemodes = {}

local GamemodePriority = {
	"Raid",
	"Dungeon",
	"Infinity Castle",
}

local PriorityMap = {
	["Raid"] = 1,
	["Dungeon"] = 2,
	["Infinity Castle"] = 3,
}

local RaidData = {}
local DungeonData = {}
local InfinityData = {}

local gamemodeFold = workspace:WaitForChild("_MAP"):WaitForChild("Gamemode")
local WaveData
local WaveLabel = LocalPlayer.PlayerGui:WaitForChild("Mode").Content.Start.Label
local sucess, playerNameFromId = pcall(function()
	return Players:GetNameFromUserIdAsync(string.match(LocalPlayer:GetAttribute("InMode"), "%d+"))
end)

local function setupGamemodeData()
	for id in pairs(GamemodeData) do
		table.insert(Gamemodes, id)
	end

	for players, names in pairs(Players:GetPlayers()) do
		table.insert(PlayersInGamemodes, names.Name)
	end

	for raids, value in pairs(GamemodeData["Raid"]) do
		table.insert(RaidData, raids)
	end

	for dungeons, value in pairs(GamemodeData["Dungeon"]) do
		table.insert(DungeonData, dungeons)
	end

	for infinity, value in pairs(GamemodeData["Infinity Castle"]) do
		table.insert(InfinityData, infinity)
	end

	for game, gamemode in pairs(game:GetDescendants()) do
		if gamemode:IsA("Folder") and gamemode.name == "Gamemode" and gamemode.Parent.Name == "_MAP" then
			gamemode:SetAttribute("IsInGamemode", false)
			gamemode:SetAttribute("GamemodeType", "")
			gamemode:SetAttribute("NextGamemode", "")
			gamemode:SetAttribute("Wave", 1)
		end
	end
end

setupGamemodeData()

local function getGamemodeWave()
	local waveText = tonumber(WaveLabel.Text:match(">(%d+)<"))

	local gamemode = workspace["_MAP"]:FindFirstChild("Gamemode")

	if gamemode then
		gamemode:SetAttribute("Wave", waveText)
	end
end

WaveLabel:GetPropertyChangedSignal("Text"):Connect(function()
	getGamemodeWave()
end)

local function autoJoinGamemode(gamemode, select: "Private" | "Public")
	if gamemode:GetAttribute("IsInGamemode") and LocalPlayer:GetAttribute("InMode") then
		return
	else
		gamemode:SetAttribute("IsInGamemode", false)
	end

	if select == "Private" then
		for playerName, key in pairs(scriptSettings.GamemodesTab.SelectedPlayersToJoin) do
			local player = Players[playerName]
			if player:GetAttribute("Mode") then
				local modeText = player:GetAttribute("Mode")
				if scriptSettings.GamemodesTab.SelectedGamemode[modeText] then
					Framework.Remote:Fire("GamemodeSystem", "Join", modeText, player.UserId)

					if LocalPlayer:GetAttribute("InMode") then
						gamemode:SetAttribute("GamemodeType", modeText)
						gamemode:SetAttribute("IsInGamemode", true)
					else
						gamemode:SetAttribute("GamemodeType", "")
						gamemode:SetAttribute("IsInGamemode", false)
					end
				end
			end
		end
	elseif select == "Public" then
		for key, playerName in pairs(Players:GetPlayers()) do
			print(playerName, key)
			local player = Players[playerName.Name]

			if player:GetAttribute("Mode") then
				local modeText = player:GetAttribute("Mode")

				if scriptSettings.GamemodesTab.SelectedGamemode[modeText] then
					Framework.Remote:Fire("GamemodeSystem", "Join", modeText, player.UserId)

					if LocalPlayer:GetAttribute("InMode") then
						gamemode:SetAttribute("GamemodeType", modeText)
						gamemode:SetAttribute("IsInGamemode", true)
					else
						gamemode:SetAttribute("GamemodeType", "")
						gamemode:SetAttribute("IsInGamemode", false)
					end
				end
			end
		end
	end
end

local function autoCreateGamemodes()
	if gamemodeFold:GetAttribute("IsInGamemode") and LocalPlayer:GetAttribute("InMode") then
		return
	else
		gamemodeFold:SetAttribute("IsInGamemode", false)
	end

	local chosen
	local bestPriority = math.huge

	for gamemode, enabled in pairs(scriptSettings.GamemodesTab.SelectedGamemode) do
		if enabled then
			local priority = PriorityMap[gamemode]

			if priority and priority < bestPriority then
				bestPriority = priority
				chosen = gamemode
			end
		end
	end

	if not chosen then
		return
	end

	local key = string.gsub("Selected" .. chosen, " ", "")
	local difficulty = string.gsub("Selected" .. chosen .. "Difficulty", " ", "")

	Framework.Remote:Fire(
		"GamemodeSystem",
		"Create",
		chosen,
		scriptSettings.GamemodesTab[key],
		scriptSettings.GamemodesTab[difficulty]
	)

	if LocalPlayer:GetAttribute("InMode") then
		gamemodeFold:SetAttribute("GamemodeType", chosen)
		gamemodeFold:SetAttribute("IsInGamemode", true)
	else
		gamemodeFold:SetAttribute("GamemodeType", "")
		gamemodeFold:SetAttribute("IsInGamemode", false)
	end
end

gamemodeFold:GetAttributeChangedSignal("Wave"):Connect(function()
	local currentGamemode = gamemodeFold:GetAttribute("GamemodeType")
	local waveAttribute = gamemodeFold:GetAttribute("Wave")
	local leaveIn = scriptSettings.GamemodesTab[currentGamemode .. "ToLeave"]

	print(currentGamemode)
	print(leaveIn)

	if leaveIn ~= 0 and waveAttribute >= leaveIn then
		Framework.Remote:Fire("GamemodeSystem", "Leave", Players[playerNameFromId].UserId)
	end
end)
