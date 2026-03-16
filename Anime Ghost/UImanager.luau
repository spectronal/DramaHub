local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local descLabel

local Framework = require(replicatedStorage.Framework.Library)
local Abbreviate = Framework:GetService("AbbreviateService")
local MultiplierService = Framework:GetService("MultiplierService")
local DebounceService = Framework:GetService("DebounceService")
local AnimationService = Framework:GetService("AnimationService")

local function changeDescriptionName()
	for _, desc in ipairs(coreGui:WaitForChild("FluentUI"):GetDescendants()) do
		if desc.ClassName == "TextLabel" and desc.Parent.ClassName == "Frame" then
			if desc.Text == "Calculing..." then
				desc.Name = "description"
				descLabel = desc
				break
			end
		end
	end

	for key, level in pairs(Framework.PlayerData.Rebirth) do
		local id, type = key:match("(.+)_(.+)")
		local rebirthType = RebirthData[id].Types[type]

		local nextLevel = level + 1
		local levelData = rebirthType.Levels[nextLevel]

		if levelData then
			local currency = rebirthType.Currency
			local playerMoney = Framework.PlayerData[currency]
			local price = levelData.Price

			nextAscension = `Remains {Abbreviate:Number(price - playerMoney)} {currency} for Level: {nextLevel}`
			descLabel.Text = nextAscension
		else
			nextAscension = "Max Ascension reached"
			descLabel.Text = nextAscension
		end
	end
end

local function refreshPlayersList(selectPlayersToJoin)
	table.clear(PlayersInGamemodes)

	for players, names in pairs(Players:GetPlayers()) do
		table.insert(PlayersInGamemodes, names.Name)
	end

	selectPlayersToJoin:SetValue(PlayersInGamemodes)
end
