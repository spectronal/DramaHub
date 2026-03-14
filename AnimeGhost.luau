local EncodingService = game:GetService("EncodingService")
local HttpService = game:GetService("HttpService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

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
		AutoChests = false,
	},
	GachaTab = {
		SelectedGacha = "",
		SelectedTarget = { "" },
		GachaDelay = 0.1,
		AutoGacha = false,
	},
	GamemodesTab = {
		SelectedGamemode = { "" },
		SelectedRaid = "",
		SelectedDungeon = "",
		SelectedInfinity = "",

		SelectedRaidDifficulty = "",
		SelectedDungeonDifficulty = "",
		SelectedInfinityDifficulty = "",

		RaidToLeave = 0,
		DungeonToLeave = 0,
		InfinityToLeave = 0,

		AutoJoinPublicGamemode = false,
		AutoJoinSelectedGamemode = false,
		AutoCreateGamemode = false,
		AutoLeaveGamemode = false,
		AutoFarmMobs = false,
	},
}

-- GetData
local TimeRewardData = Framework:GetData("TimeRewardData")
local WeeklyRewardData = Framework:GetData("WeeklyRewardData")
local WeeklyRewardService = Framework:GetService("WeeklyRewardService")
local RebirthData = Framework:GetData("RebirthData")
local AchievementData = Framework:GetData("AchievementData")
local ChestData = Framework:GetData("ChestData")
local GachaData = Framework:GetData("GachaData")
local GamemodeData = Framework:GetData("GamemodeData")

-- Gacha
local Gachas = {}
local Targets = {}

for id in pairs(GachaData) do
	table.insert(Gachas, id)
end

-- Gamemodes
local PlayersInGamemodes = {}
local Gamemodes = {}

local RaidData = {}
local DungeonData = {}
local InfinityData = { "Infinity Castle" }

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

--[[for targetId in pairs(GachaData[selectedGacha].Targets) do
    table.insert(Targets,targetId)
end]]
-- Ascension
local nextAscension = "Calculing..."

-- Achievements

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

local function autoGachas(Gacha: string, Target)
	Framework.Remote:Fire("GachaSystem", "Spin", Gacha, "Normal", {}, Target)
end

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

local function removeCutscene()
	local oldRequire = require

	require = function(module)
		if module == Framework.Modules.Client.Controllers.CutsceneController.Ascension then
			return function() end
		end

		return oldRequire(module)
	end
end

local function removeGachaAnimation()
	local mod = require(Framework.Modules.Services.GachaService)

	mod.SetupAnimation = function()
		return
	end
	mod.QuitAnimation = function()
		return
	end
	mod.StartAnimation = function()
		return
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

local function autoChests()
	for chestId, chestConfig in pairs(ChestData) do
		if chestConfig.CanClaim(Framework.LocalPlayer) then
			Framework.Remote:Fire("ChestSystem", "Claim", chestId)
		end
	end
end

local function autoJoinGamemode()
	-- Example: Auto join "Survival" gamemode
	Framework.Remote:Fire("GameModeSystem", "Join", scriptSettings.GamemodesTab.SelectedGamemode)
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
	Gachas = Window:AddTab({ Title = "Gachas", Icon = "clover" }),
	Gamemode = Window:AddTab({ Title = "Gamemodes", Icon = "gamepad-2" }),
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
local mainPlayer = Tabs.Player:AddSection("Main")
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

local mainPlayer2 = Tabs.Player:AddSection("Auto Collect")

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

local autoChest = mainPlayer2:AddToggle("AutoChests", {
	Title = "Auto Collect Chest",
	Default = false,
	Callback = function(state)
		scriptSettings.PlayerTab.AutoChests = state
	end,
})

-- GACHA
local mainGacha = Tabs.Gachas:AddSection("Main")
mainGacha:AddParagraph({
	Title = "Gacha Features",
	Content = "\nHere you can find various features related to gacha mechanics.",
})

local selectGacha = mainGacha:AddDropdown("selectGacha", {
	Title = "Select Gacha",
	Description = "Select a gacha to spin",
	Values = Gachas,
	Multi = false,
	Default = "Psychic Power",
})

local selectGachaTarget = mainGacha:AddDropdown("selectGachaTarget", {
	Title = "Select Target",
	Description = "Select your target for spin",
	Values = Targets,
	Multi = true,
	Default = { "Choose a target" },
})

local autoGacha = mainGacha:AddToggle("autoGacha", {
	Title = "Auto Gacha",
	Default = false,
	Callback = function(state)
		scriptSettings.GachaTab.AutoGacha = state
	end,
})

local gachaSettings = Tabs.Gachas:AddSection("Settings")

local gachaDelay = gachaSettings:AddSlider("gachaDelay", {
	Title = "Spin Delay",
	Description = "Set the delay between each spin (in seconds)",
	Default = 0.1,
	Min = 0.1,
	Max = 5,
	Rounding = 0.1,
	Callback = function(Value)
		scriptSettings.GachaTab.GachaDelay = Value
	end,
})

local removeGachaAnim = gachaSettings:AddButton({
	Title = "Remove Gacha Animation",
	Callback = function()
		removeGachaAnimation()
	end,
})

-- GAMEMODE
local mainGamemode = Tabs.Gamemode:AddSection("Main")
mainGamemode:AddParagraph({
	Title = "Gamemode Features",
	Content = "\nHere you can find various features related to gamemodes.",
})

local selectGamemode = mainGamemode:AddDropdown("selectGamemode", {
	Title = "Select Gamemode",
	Description = "Select a gamemode to play",
	Values = Gamemodes,
	Multi = true,
	Default = { "Choose a gamemode" },
})

local autoFarmGamemodeMobs = mainGamemode:AddToggle("AutoFarmMobs", {
	Title = "Auto Farm Mobs",
	Default = false,
	Callback = function(state)
		scriptSettings.GamemodesTab.AutoFarmMobs = state
	end,
})

local mapsGamemode = Tabs.Gamemode:AddSection("Maps")

local selectRaid = mapsGamemode:AddDropdown("selectRaid", {
	Title = "Select Raid",
	Description = "Select an raid map",
	Values = RaidData,
	Multi = false,
	Default = "Choose an raid map",
})

local selectDungeon = mapsGamemode:AddDropdown("selectDungeon", {
	Title = "Select Dungeon",
	Description = "Select an dungeon map",
	Values = DungeonData,
	Multi = false,
	Default = "Choose an dungeon map",
})

local selectInfinity = mapsGamemode:AddDropdown("selectInfinity", {
	Title = "Select Infinity",
	Description = "Select an infinity map",
	Values = InfinityData,
	Multi = false,
	Default = "Choose an infinity map",
})

local leaveGamemode = Tabs.Gamemode:AddSection("Leave in")

local raidLeaveIn = leaveGamemode:AddInput("raidLeaveIn", {
	Title = "Raid Leave In",
	Default = "",
	Placeholder = "e.g 30",
	Numeric = true,
	Finished = false,
	Callback = function(Value)
		scriptSettings.GamemodesTab.RaidToLeave = Value
	end,
})

local dungeonLeaveIn = leaveGamemode:AddInput("dungeonLeaveIn", {
	Title = "Dungeon Leave In",
	Default = "",
	Placeholder = "e.g 30",
	Numeric = true,
	Finished = false,
	Callback = function(Value)
		scriptSettings.GamemodesTab.DungeonToLeave = Value
	end,
})

local infinityLeaveIn = leaveGamemode:AddInput("infinityLeaveIn", {
	Title = "Infinity Leave In",
	Default = "",
	Placeholder = "e.g 30",
	Numeric = true,
	Finished = false,
	Callback = function(Value)
		scriptSettings.GamemodesTab.InfinityToLeave = Value
	end,
})

local autoLeaves = leaveGamemode:AddToggle("autoLeave", {
	Title = "Auto Leave Gamemode",
	Default = false,
	Callback = function(state)
		scriptSettings.GamemodesTab.AutoLeaveGamemode = state
	end,
})

local playerGamemode = Tabs.Gamemode:AddSection("Player Settings")

local selectPlayersToJoin = playerGamemode:AddDropdown("selectPlayersToJoin", {
	Title = "Select Player's Party to Join",
	Description = "Select players to join the gamemode",
	Values = PlayersInGamemodes,
	Multi = true,
	Default = { "Choose a player" },
})

local refreshPlayers = playerGamemode:AddButton({
	Title = "Refresh Players List",
	Callback = function()
		table.clear(PlayersInGamemodes)

		for players, names in pairs(Players:GetPlayers()) do
			table.insert(PlayersInGamemodes, names.Name)
		end

		selectPlayersToJoin:SetValue(PlayersInGamemodes)
	end,
})

local autoJoinSelected = playerGamemode:AddToggle("autoJoinSelected", {
	Title = "Auto Join Gamemode (Selected Players)",
	Default = false,
	Callback = function(state)
		scriptSettings.GamemodesTab.AutoJoinSelectedGamemode = state
	end,
})

local autoJoinPublic = playerGamemode:AddToggle("autoJoinPublic", {
	Title = "Auto Join Gamemode (Public)",
	Default = false,
	Callback = function(state)
		scriptSettings.GamemodesTab.AutoJoinPublicGamemode = state
	end,
})

local autoCreateGamemode = playerGamemode:AddToggle("autoCreateGamemode", {
	Title = "Auto Create Gamemode",
	Default = false,
	Callback = function(state)
		scriptSettings.GamemodesTab.AutoCreateGamemode = state
	end,
})

-- Spawn functions
selectGacha:OnChanged(function(Value)
	table.clear(Targets)
	scriptSettings.GachaTab.SelectedGacha = Value

	for targetId in pairs(GachaData[Value].Targets) do
		if not table.find(Targets, targetId) then
			table.insert(Targets, targetId)
		end
	end

	selectGachaTarget:SetValue(Targets)
end)

selectGachaTarget:OnChanged(function(Value)
	scriptSettings.GachaTab.SelectedTarget = Value
end)

task.spawn(function()
	while true do
		task.wait(1)
		changeDescriptionName()
	end
end)

task.spawn(function()
	while true do
		task.wait(scriptSettings.GachaTab.GachaDelay)

		if scriptSettings.GachaTab.AutoGacha and scriptSettings.GachaTab.SelectedGacha ~= "" then
			autoGachas(scriptSettings.GachaTab.SelectedGacha, scriptSettings.GachaTab.SelectedTarget)
		end
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

			if scriptSettings.PlayerTab.AutoChests then
				autoChests()
			end
		end
	end
end)
