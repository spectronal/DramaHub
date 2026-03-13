local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local players = game:GetService("Players")
local player = players.LocalPlayer

local descLabel

local Framework = require(replicatedStorage.Framework.Library)
local Abbreviate = Framework:GetService("AbbreviateService")
local MultiplierService = Framework:GetService("MultiplierService")
local DebounceService = Framework:GetService("DebounceService")
local AnimationService = Framework:GetService("AnimationService")

local scriptSettings = {
	PlayerTab = {
		AutoClick = false,
		AutoClickAnimation = false,
		AutoAscension = false,
		AutoRewards = false,
		AutoAchievments = false,
	},
}

-- Rewards
local TimeRewardData = Framework:GetData("TimeRewardData")
local WeeklyRewardData = Framework:GetData("WeeklyRewardData")
local WeeklyRewardService = Framework:GetService("WeeklyRewardService")

-- Ascension

local nextAscension = "Calculing..."
local RebirthData = Framework:GetData("RebirthData")
local RebirthGui = Framework:GetGuiFrame("Rebirth")

-- Achievements
local AchievementData = Framework:GetData("AchievementData")

local function GetCurrentTier(typeName)
	local completed = 0

	for id, _ in Framework.PlayerData.Achievements do
		if id:match(typeName) then
			completed += 1
		end
	end

	local nextTier = completed + 1

	if AchievementData[typeName .. nextTier] then
		return typeName .. nextTier, nextTier
	else
		return typeName .. completed, completed
	end
end

local function GetAchievementTypes()
	local types = {}

	for key, _ in AchievementData do
		local name = string.gsub(key, "%d+", "")

		if not table.find(types, name) then
			table.insert(types, name)
		end
	end

	return types
end

local function GetClaimableAchievements()
	local claimable = {}

	for _, typeName in GetAchievementTypes() do
		local id = GetCurrentTier(typeName)

		local data = AchievementData[id]

		local stat = Framework.PlayerData.TotalStats[data.DataUsed] or 0

		local goal = data.Goal

		stat = math.min(stat, goal)

		local claimed = Framework.PlayerData.Achievements[id] or false

		if goal <= stat and not claimed then
			claimable[id] = true
		end
	end

	return claimable
end

-- AutoClicker with animation
local lastClickTime = tick()
local comboIndex = 0

-- functions

local function autoClicker()
	Framework.Remote:Fire("ClickSystem", "Execute", Framework.Target)
end

local function autoClickerWithAnimation()
	if Framework.LocalPlayer:GetAttribute("UsingSkill") then
		return
	end

	if DebounceService.Check(Framework.LocalPlayer, "Click", 0.05) then
		return
	end

	Framework.Remote:Fire("ClickSystem", "Execute", Framework.Target)

	local atkSpeed = MultiplierService.AtkSPD(Framework.LocalPlayer)
	local animationSpeed = 0.6 / atkSpeed

	if not DebounceService.Check(Framework.LocalPlayer, "ClickAnimation", atkSpeed * 1.1) then
		-- combo system
		comboIndex += 1

		if tick() - lastClickTime > 2 then
			comboIndex = 1
		end

		if comboIndex > 3 then
			comboIndex = 1
		end

		lastClickTime = tick()

		local animationType = "Punch"

		if not Framework.PlayerData.Settings.HideWeapon then
			local weaponTypes = {
				"Weapon",
				"DualWeapon",
				"TripleWeapon",
			}

			local equipped = #Framework.PlayerData.WeaponsEquipped

			if equipped > 0 then
				animationType = weaponTypes[equipped]
			end
		end

		if not Framework.LocalPlayer:GetAttribute("OnMount") then
			AnimationService.Load(
				Framework.LocalPlayer.Character.Humanoid.Animator,
				("%s %s"):format(animationType, comboIndex),
				animationSpeed,
				"Action2"
			)
		end
	end
end

local function autoAscension()
	for key, level in pairs(Framework.PlayerData.Rebirth) do
		local id, type = key:match("(.+)_(.+)")
		local rebirthType = RebirthData[id].Types[type]

		local nextLevel = level + 1
		local levelData = rebirthType.Levels[nextLevel]

		if levelData then
			local currency = rebirthType.Currency
			local playerMoney = Framework.PlayerData[currency]
			local price = levelData.Price

			if playerMoney >= price then
				Framework.Remote:Fire("RebirthSystem", "Release", id, type)
			end
		end
	end
end

--[[                   while scriptSettings.PlayerTab.AutoAscension do
                            task.wait(1)
                            desc.Text = nextAscension
                        end]]

local function removeCutscene()
	local oldRequire = require

	require = function(module)
		if module == Framework.Modules.Client.Controllers.CutsceneController.Ascension then
			return function() end
		end

		return oldRequire(module)
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
					--print("Claiming reward", typeName, index)
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

local function autoAchievements()
	for _, typeName in GetAchievementTypes() do
		local id = GetCurrentTier(typeName)

		if GetClaimableAchievements()[id] then
			Framework.Remote:Fire("AchievementSystem", "Claim", id)
		end
	end
end

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

-- UI

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")
)()

coreGui:FindFirstChild("ScreenGui").Name = "FluentUI"

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

local autoClickAnimation = mainPlayer:AddToggle("AutoClickAnimation", {
	Title = "Auto Click with Animation",
	Default = false,
	Callback = function(state)
		scriptSettings.PlayerTab.AutoClickAnimation = state
	end,
})

local autoClick = mainPlayer:AddToggle("AutoClick", {
	Title = "Auto Click without Animation",
	Default = false,
	Callback = function(state)
		scriptSettings.PlayerTab.AutoClick = state
	end,
})

local autoAscend = mainPlayer:AddToggle("AutoAscencion", {
	Title = "Auto Ascension",
	Description = nextAscension,
	Default = false,
	Callback = function(state)
		scriptSettings.PlayerTab.AutoAscension = state
	end,
})

local removeCuts = mainPlayer:AddButton({
	Title = "Remove Ascension Cutscene",
	Callback = function()
		removeCutscene()
	end,
})

local mainPlayer2 = Tabs.Player:AddSection("")

local autoReward = mainPlayer2:AddToggle("AutoRewards", {
	Title = "Auto Collect Rewards",
	Default = false,
	Callback = function(state)
		scriptSettings.PlayerTab.AutoRewards = state
	end,
})

local autoAchievement = mainPlayer2:AddToggle("AutoAchievements", {
	Title = "Auto Collect Achievements",
	Default = false,
	Callback = function(state)
		scriptSettings.PlayerTab.AutoAchievements = state
	end,
})

-- Spawn functions

task.spawn(function()
	while true do
		task.wait(1)
		changeDescriptionName()
	end
end)

task.spawn(function()
	local rewardTimer = 0

	while true do
		local dt = task.wait()

		if scriptSettings.PlayerTab.AutoClick then
			autoClickAnimation:SetValue(false)
			autoClicker()
		end

		if scriptSettings.PlayerTab.AutoClickAnimation then
			autoClick:SetValue(false)
			autoClickerWithAnimation()
		end

		rewardTimer += dt
		if rewardTimer >= 1 then
			rewardTimer = 0
			if scriptSettings.PlayerTab.AutoRewards then
				autoRewards()
			end

			if scriptSettings.PlayerTab.AutoAscension then
				autoAscension()
			end

			if scriptSettings.PlayerTab.AutoAchievements then
				autoAchievements()
			end
		end
	end
end)
