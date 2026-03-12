local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local player = players.LocalPlayer

local Framework = require(replicatedStorage.Framework.Library)

local scriptSettings = {
	PlayerTab = {
		AutoClick = false,
		AutoAscension = false,
		AutoRewards = false,
	},
}

-- Rewards
local TimeRewardData = Framework:GetData("TimeRewardData")

local ServerRewards = Framework.Replicated.Server.WeeklyRewards
local WeeklyRewardsGui = Framework:GetGuiFrame("WeeklyRewards")
local WeeklyRewardData = Framework:GetData("WeeklyRewardData")
local WeeklyRewardService = Framework:GetService("WeeklyRewardService")
local WeeklyRewardsGui = Framework:GetGuiFrame("WeeklyRewards")

local currentType = WeeklyRewardsGui:GetAttribute("Type")
local rewardDataEncoded = ServerRewards:GetAttribute(currentType)
local rewardList = Framework:Decode(rewardDataEncoded)
local currentDay = WeeklyRewardService.CurrentDay()
--local weeklyTime = weeklyFolder:GetAttribute("TimeLeft")

-- Ascension
local RebirthData = Framework:GetData("RebirthData")
local RebirthGui = Framework:GetGuiFrame("Rebirth")

local id = RebirthGui:GetAttribute("Id")
local type = RebirthGui:GetAttribute("Type")

local rebirthType = RebirthData[id].Types[type]

local nextLevel = Framework.PlayerData.Rebirth[("%s_%s"):format(id, type)] + 1

local function GetRebirthState()
	local id = RebirthGui:GetAttribute("Id")
	local type = RebirthGui:GetAttribute("Type")

	local level = Framework.PlayerData.Rebirth[("%s_%s"):format(id, type)]

	local maxLevel = RebirthData[id].Types[type].MaxLevel

	return {

		IsMaxed = level == maxLevel,

		CanSingleSkip = level < maxLevel,

		CanMultiSkip = level < maxLevel - 4,
	}
end

-- functions

local function autoClicker()
	Framework.Remote:Fire("ClickSystem", "Execute", Framework.Target)
end

local function autoAscension()
	local rebirthState = GetRebirthState()

	if rebirthType.Levels[nextLevel] and not rebirthState.IsMaxed then
		local currency = rebirthType.Currency
		local playerMoney = Framework.PlayerData[currency]
		local price = rebirthType.Levels[nextLevel].Price

		if price <= playerMoney then
			Framework.Remote:Fire("RebirthSystem", "Ascension", "Normal")
		end
	end
end

local function autoRewards()
	local PlayerData = Framework.PlayerData
	--  print(PlayerData and PlayerData.TimeRewards)

	for typeName, config in pairs(TimeRewardData) do
		local data = PlayerData.TimeRewards[typeName]

		if data then
			local time = data.Time

			for index, reward in pairs(config.Rewards) do
				if not data.Claimed[index] and reward.Time < time then
					Framework.Remote:Fire("TimeRewardSystem", "Claim", typeName, index)
					--                   print("Claiming reward", typeName, index)
				end
			end

			if time >= config.ResetTime then
				Framework.Remote:Fire("TimeRewardSystem", "Reset", typeName)
			end
		end
	end

	local currentDay = WeeklyRewardService.CurrentDay()

	for typeName, _ in pairs(WeeklyRewardData) do
		local playerData = Framework.PlayerData.WeeklyRewards[typeName]
		if playerData then
			if not playerData.Claimed[tostring(currentDay)] and WeeklyRewardService.HOUR_TIME <= playerData.Time then
				Framework.Remote:Fire("WeeklyRewardSystem", "Claim", typeName, currentDay)
			end
		end
	end
end

-- UI

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")
)()

Fluent:Notify({
	Title = "Drama Hub | Development Build",
	Content = "Loading...",
	Duration = 2,
})

task.wait(2.2)

local Window = Fluent:CreateWindow({
	Title = "Drama Hub | Development Build",
	SubTitle = "by spectronal",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = false,
	Theme = "Darker",
	MinimizeKey = Enum.KeyCode.LeftControl,
})

local Tabs = {
	About = Window:AddTab({ Title = "About", Icon = "clipboard" }),
	Player = Window:AddTab({ Title = "Player", Icon = "smile-plus" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

Window:SelectTab(1)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- ABOUT
local mainAbout = Tabs.About:AddSection("Drama Hub")

mainAbout:AddParagraph({
	Title = "Version Development Build",
	Content = "\nThis is a development build of Drama Hub, an all-in-one script for Anime Ghost. \nThis build is not intended for public use and may contain bugs or unfinished features.\n\nCreated by spectronal",
})

-- PLAYER
local mainPlayer = Tabs.Player:AddSection("")
mainPlayer:AddParagraph({
	Title = "Player Features",
	Content = "\nHere you can find various features related to the player, such as auto-clicker and auto-rewards.",
})

local autoClick = Tabs.Player:AddToggle("AutoClick", {
	Title = "Auto Click",
	Default = false,
	Callback = function(state)
		scriptSettings.PlayerTab.AutoClick = state
	end,
})

local autoAscend = Tabs.Player:AddToggle("AutoAscencion", {
	Title = "Auto Ascension",
	Default = false,
	Callback = function(state)
		scriptSettings.PlayerTab.AutoAscension = state
	end,
})

local autoReward = Tabs.Player:AddToggle("AutoRewards", {
	Title = "Auto Rewards",
	Default = false,
	Callback = function(state)
		scriptSettings.PlayerTab.AutoRewards = state
	end,
})

task.spawn(function()
	local rewardTimer = 0

	while true do
		local dt = task.wait()

		if scriptSettings.PlayerTab.AutoClick then
			autoClicker()
		end

		if scriptSettings.PlayerTab.AutoAscension then
			autoAscension()
		end

		rewardTimer += dt
		if rewardTimer >= 1 then
			rewardTimer = 0
			if scriptSettings.PlayerTab.AutoRewards then
				autoRewards()
			end
		end
	end
end)
