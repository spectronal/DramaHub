-- Main.lua
-- DramaHub: Anime Ghost
-- Version: 1.0.85
-- Update Logs: for Gamemode: Added Auto Farm Mobs, Save Position/Return World and Status Mode (QOL), for general: Added custom DramaHub Roles, Result UI is not appearing anymore and new Hub notifiers (QOL)
-- Errors: 1.5 (1: Warriors is not focusing in the main enemy in gamemodes, idk how i'll fix it | 0.5: I think the general performance is bad, i'll fix it tomorrow)
-- Expected for 1.0.9: New Farm Tab (with autofarm for all the maps + autofarm mobs with scroll hatch), New Scroll Tab (Scroll Farm for all the maps btw), New Section of Equip best in Gamemode Tab, and for end, new Exchange Tab (for potions and tokens)

DRAMAHUB_VERSION = "DEVELOPMENT BUILD"
AUTHOR = 10544785935

local BASE_URL = "https://raw.githubusercontent.com/spectronal/DramaHub/refs/heads/main/AnimeGhostBuild"

local URLS = {
	State = BASE_URL .. "/Systems/State.lua",
	Utils = BASE_URL .. "/Core/Utils.lua",
	Player = BASE_URL .. "/Core/Player.lua",
	Rewards = BASE_URL .. "/Core/Rewards.lua",
	Farm = BASE_URL .. "/Core/Farm.lua",
	Gamemode = BASE_URL .. "/Core/Gamemode.lua",
	Gacha = BASE_URL .. "/Core/Gacha.lua",
}

-- Loader

local loadOrder = {
	"State",
	"Utils",
	"Player",
	"Rewards",
	"Gacha",
	"Gamemode",
	"Farm",
}

for _, name in ipairs(loadOrder) do
	local ok, err = pcall(function()
		loadstring(game:HttpGet(URLS[name]))()
	end)

	if not ok then
		warn("[DramaHub] Failed to load module '" .. name .. "': " .. tostring(err))
	end
end

local State = getgenv().DH.State
local Utils = getgenv().DH.Utils
local Player = getgenv().DH.Player
local Rewards = getgenv().DH.Rewards
local Farm = getgenv().DH.Farm
local Gamemode = getgenv().DH.Gamemode
local Gacha = getgenv().DH.Gacha

-- Services

local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Framework = State.Framework

for _, f in pairs(getgc(true)) do
	if typeof(f) == "function" and islclosure(f) then
		local success, constants = pcall(debug.getconstants, f)

		if success and constants and table.find(constants, "PlayerBillboards") then
			hookfunction(f, function(...)
				return nil
			end)
		end
	end
end

LocalPlayer.PlayerGui.Results.Content.Visible = false

Gamemode.setupGamemodeData()

-- UI

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")
)()

coreGui:FindFirstChild("ScreenGui").Name = "DramaHub"
coreGui:FindFirstChild("DramaHub").DisplayOrder = 9999
coreGui:FindFirstChild("DramaHub").Parent = LocalPlayer.PlayerGui

-- Notifiers

Fluent:Notify({
	Title = "Drama Hub | Development Build",
	Content = "Loading...",
	Duration = 2,
})

task.wait(2.2)

if LocalPlayer.UserId == AUTHOR then
	Fluent:Notify({
		Title = "Drama Hub | Owner Acess",
		Content = "Welcome back spectronal!",
		Duration = 2,
	})
else
	Fluent:Notify({
		Title = "Drama Hub | Premium Acess",
		Content = "Welcome back " .. LocalPlayer.Name,
		Duration = 2,
	})
end

-- Window & Tabs

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
	Farm = Window:AddTab({ Title = "Farm", Icon = "bot" }),
	Player = Window:AddTab({ Title = "Player", Icon = "smile-plus" }),
	Gamemode = Window:AddTab({ Title = "Gamemodes", Icon = "gamepad-2" }),
	Scroll = Window:AddTab({ Title = "Scroll", Icon = "scroll" }),
	Gachas = Window:AddTab({ Title = "Gachas", Icon = "clover" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

Window:SelectTab(1)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Tab: About

local mainAbout = Tabs.About:AddSection("Drama Hub")
mainAbout:AddParagraph({
	Title = "Version Development Build",
	Content = "\nThis is a development build of Drama Hub, an all-in-one script for Anime Ghost. \nThis build is not intended for public use and may contain bugs or unfinished features.\n\nCreated by spectronal",
})

-- Tab: Player

local mainPlayer = Tabs.Player:AddSection("Main")
mainPlayer:AddParagraph({
	Title = "Player Features",
	Content = "\nHere you can find various features related to the player, such as auto-clicker and auto-rewards.",
})

local autoClickAnimation = mainPlayer:AddToggle("AutoClickAnimation", {
	Title = "Auto Click with Animation",
	Default = false,
	Callback = function(state)
		State.scriptSettings.PlayerTab.AutoClickAnimation = state
	end,
})

local autoClick = mainPlayer:AddToggle("AutoClick", {
	Title = "Auto Click without Animation",
	Default = false,
	Callback = function(state)
		State.scriptSettings.PlayerTab.AutoClick = state
	end,
})

local autoAscend = mainPlayer:AddToggle("AutoAscencion", {
	Title = "Auto Ascension",
	Description = "Calculing...",
	Default = false,
	Callback = function(state)
		State.scriptSettings.PlayerTab.AutoAscension = state
	end,
})

mainPlayer:AddButton({
	Title = "Remove Ascension Cutscene",
	Callback = function()
		Player.removeCutscene()
	end,
})

local mainPlayer2 = Tabs.Player:AddSection("Auto Collect")

mainPlayer2:AddToggle("AutoRewards", {
	Title = "Auto Collect Rewards",
	Default = false,
	Callback = function(state)
		State.scriptSettings.PlayerTab.AutoRewards = state
	end,
})

mainPlayer2:AddToggle("AutoAchievements", {
	Title = "Auto Collect Achievements",
	Default = false,
	Callback = function(state)
		State.scriptSettings.PlayerTab.AutoAchievements = state
	end,
})

mainPlayer2:AddToggle("AutoChests", {
	Title = "Auto Collect Chest",
	Default = false,
	Callback = function(state)
		State.scriptSettings.PlayerTab.AutoChests = state
	end,
})

-- Tab: Gachas

local mainGacha = Tabs.Gachas:AddSection("Main")
mainGacha:AddParagraph({
	Title = "Gacha Features",
	Content = "\nHere you can find various features related to gacha mechanics.",
})

local selectGacha = mainGacha:AddDropdown("selectGacha", {
	Title = "Select Gacha",
	Description = "Select a gacha to spin",
	Values = State.Gachas,
	Multi = false,
	Default = "Psychic Power",
})

local selectGachaTarget = mainGacha:AddDropdown("selectGachaTarget", {
	Title = "Select Target",
	Description = "Select your target for spin",
	Values = State.Targets,
	Multi = true,
	Default = { "Choose a target" },
})

mainGacha:AddToggle("autoGacha", {
	Title = "Auto Gacha",
	Default = false,
	Callback = function(state)
		State.scriptSettings.GachaTab.AutoGacha = state
	end,
})

local gachaSettings = Tabs.Gachas:AddSection("Settings")

gachaSettings:AddSlider("gachaDelay", {
	Title = "Spin Delay",
	Description = "Set the delay between each spin (in seconds)",
	Default = 0.1,
	Min = 0.1,
	Max = 5,
	Rounding = 0.1,
	Callback = function(Value)
		State.scriptSettings.GachaTab.GachaDelay = Value
	end,
})

gachaSettings:AddButton({
	Title = "Remove Gacha Animation",
	Callback = function()
		Gacha.removeGachaAnimation()
	end,
})

-- Tab: Gamemodes

local mainGamemode = Tabs.Gamemode:AddSection("Main")
mainGamemode:AddParagraph({
	Title = "Gamemode Features",
	Content = "\nHere you can find various features related to gamemodes.",
})

local selectGamemode = mainGamemode:AddDropdown("selectGamemode", {
	Title = "Select Gamemode",
	Description = "Select a gamemode to play",
	Values = State.Gamemodes,
	Multi = true,
	Default = { "Choose a gamemode" },
})

mainGamemode:AddToggle("AutoFarmMobs", {
	Title = "Auto Farm Mobs",
	Default = false,
	Callback = function(state)
		State.scriptSettings.GamemodesTab.AutoFarmMobs = state
	end,
})

-- Maps
local mapsGamemode = Tabs.Gamemode:AddSection("Maps")

local selectRaid = mapsGamemode:AddDropdown("selectRaid", {
	Title = "Select Raid",
	Description = "Select an raid map",
	Values = State.RaidData,
	Multi = false,
	Default = "Choose an raid map",
})

local selectDungeon = mapsGamemode:AddDropdown("selectDungeon", {
	Title = "Select Dungeon",
	Description = "Select an dungeon map",
	Values = State.DungeonData,
	Multi = false,
	Default = "Choose an dungeon map",
})

local selectInfinity = mapsGamemode:AddDropdown("selectInfinity", {
	Title = "Select Infinity",
	Description = "Select an infinity map",
	Values = State.InfinityData,
	Multi = false,
	Default = "Choose an infinity map",
})

-- Difficulties
local diffGamemode = Tabs.Gamemode:AddSection("Difficulties")

local selectRaidDiff = diffGamemode:AddDropdown("selectRaidDiff", {
	Title = "Select Raid Diff",
	Description = "Select a difficulty for raids",
	Values = { "Easy", "Medium", "Hard" },
	Multi = false,
	Default = "",
})

local selectDungeonDiff = diffGamemode:AddDropdown("selectDungeonDiff", {
	Title = "Select Dungeon Diff",
	Description = "Select a difficulty for dungeons",
	Values = { "Easy", "Medium", "Hard" },
	Multi = false,
	Default = "",
})

local selectInfinityDiff = diffGamemode:AddDropdown("selectInfinityDiff", {
	Title = "Select Infinity Diff",
	Description = "Select a difficulty for infinity castle",
	Values = { "Easy" },
	Multi = false,
	Default = "",
})

-- Leave In
local leaveGamemode = Tabs.Gamemode:AddSection("Leave in")

leaveGamemode:AddInput("raidLeaveIn", {
	Title = "Raid Leave In",
	Default = 0,
	Placeholder = "e.g 30",
	Numeric = true,
	Finished = true,
	Callback = function(Value)
		State.scriptSettings.GamemodesTab.RaidToLeave = Value
	end,
})

leaveGamemode:AddInput("dungeonLeaveIn", {
	Title = "Dungeon Leave In",
	Default = 0,
	Placeholder = "e.g 30",
	Numeric = true,
	Finished = true,
	Callback = function(Value)
		State.scriptSettings.GamemodesTab.DungeonToLeave = Value
	end,
})

leaveGamemode:AddInput("infinityLeaveIn", {
	Title = "Infinity Leave In",
	Default = 0,
	Placeholder = "e.g 30",
	Numeric = true,
	Finished = true,
	Callback = function(Value)
		State.scriptSettings.GamemodesTab.InfinityCastleToLeave = Value
	end,
})

leaveGamemode:AddToggle("autoLeave", {
	Title = "Auto Leave Gamemode",
	Default = false,
	Callback = function(state)
		State.scriptSettings.GamemodesTab.AutoLeaveGamemode = state
	end,
})

-- Settings
local playerGamemode = Tabs.Gamemode:AddSection("Settings")

playerGamemode:AddParagraph({
	Title = "Status",
	Content = "StatusMode",
})

local saveWorldToTp = playerGamemode:AddDropdown("WorldToTp", {
	Title = "World To Teleport",
	Description = "Select a world to back",
	Values = State.MapsNum,
	Multi = false,
	Default = "",
})

playerGamemode:AddButton({
	Title = "Save Position",
	Callback = function()
		Gamemode.savePlayerPosition()

		Fluent:Notify({
			Title = "Saved Position!",
			Content = "Position: "
				.. tostring(State.scriptSettings.GamemodesTab.SavedPosition)
				.. " | World: "
				.. tostring(State.scriptSettings.GamemodesTab.WorldToTeleport),
			Duration = 2,
		})
	end,

	Gamemode.changeDescriptionPlayerStatus(Player.setDescription),
})

playerGamemode:AddToggle("AutoCreateGamemode", {
	Title = "Auto Create Gamemode",
	Default = false,
	Callback = function(state)
		State.scriptSettings.GamemodesTab.AutoCreateGamemode = state
	end,
})

local playerGamemode2 = Tabs.Gamemode:AddSection("")

local selectPlayersToJoin = playerGamemode2:AddDropdown("selectPlayersToJoin", {
	Title = "Select Player's Party to Join",
	Description = "Select players to join the gamemode",
	Values = State.PlayersInGamemodes,
	Multi = true,
	Default = {},
})

playerGamemode2:AddButton({
	Title = "Refresh Players List",
	Callback = function()
		table.clear(State.PlayersInGamemodes)

		for _, names in pairs(Players:GetPlayers()) do
			table.insert(State.PlayersInGamemodes, names.Name)
		end

		selectPlayersToJoin:SetValue(State.PlayersInGamemodes)
	end,
})

playerGamemode2:AddToggle("autoJoinSelected", {
	Title = "Auto Join Gamemode (Selected Players)",
	Default = false,
	Callback = function(state)
		State.scriptSettings.GamemodesTab.AutoJoinSelectedGamemode = state
	end,
})

playerGamemode2:AddToggle("autoJoinPublic", {
	Title = "Auto Join Gamemode (Public)",
	Default = false,
	Callback = function(state)
		State.scriptSettings.GamemodesTab.AutoJoinPublicGamemode = state
	end,
})

-- Dropdown OnChanged Handlers

selectGacha:OnChanged(function(Value)
	table.clear(State.Targets)
	State.scriptSettings.GachaTab.SelectedGacha = Value

	for targetId in pairs(State.GachaData[Value].Targets) do
		if not table.find(State.Targets, targetId) then
			table.insert(State.Targets, targetId)
		end
	end

	selectGachaTarget:SetValue(State.Targets)
end)

selectGachaTarget:OnChanged(function(Value)
	State.scriptSettings.GachaTab.SelectedTarget = Value
end)

selectGamemode:OnChanged(function(Value)
	State.scriptSettings.GamemodesTab.SelectedGamemode = Value
end)

selectRaidDiff:OnChanged(function(Value)
	State.scriptSettings.GamemodesTab.SelectedRaidDifficulty = Value
end)

selectDungeonDiff:OnChanged(function(Value)
	State.scriptSettings.GamemodesTab.SelectedDungeonDifficulty = Value
end)

selectInfinityDiff:OnChanged(function(Value)
	State.scriptSettings.GamemodesTab.SelectedInfinityCastleDifficulty = Value
end)

selectRaid:OnChanged(function(Value)
	State.scriptSettings.GamemodesTab.SelectedRaid = Value
end)

selectDungeon:OnChanged(function(Value)
	State.scriptSettings.GamemodesTab.SelectedDungeon = Value
end)

selectInfinity:OnChanged(function(Value)
	State.scriptSettings.GamemodesTab.SelectedInfinityCastle = Value
end)

selectPlayersToJoin:OnChanged(function(Value)
	State.scriptSettings.GamemodesTab.SelectedPlayersToJoin = Value
end)

saveWorldToTp:OnChanged(function(Value)
	State.scriptSettings.GamemodesTab.WorldToTeleport = Value
end)

-- Description helpers (Ascension)

local Abbreviate = Framework:GetService("AbbreviateService")

local function changeDescriptionAscension()
	Player.registerDescriptions()

	for key, level in pairs(Framework.PlayerData.Rebirth) do
		local id, type = key:match("(.+)_(.+)")
		local rebirthType = State.RebirthData[id].Types[type]
		local nextLevel = level + 1
		local levelData = rebirthType.Levels[nextLevel]

		if levelData then
			local currency = rebirthType.Currency
			local playerMoney = Framework.PlayerData[currency]
			local price = levelData.Price

			Player.setDescription(
				"Ascension",
				`Remains {Abbreviate:Number(price - playerMoney)} {currency} for Level: {nextLevel}`
			)
		else
			Player.setDescription("Ascension", "Max Ascension reached")
		end
	end
end

local function changeDescriptionPlayerStatus()
	Player.registerDescriptions()
	Gamemode.changeDescriptionPlayerStatus(Player.setDescription)
end

-- Loops

task.spawn(function()
	while true do
		task.wait(State.scriptSettings.GachaTab.GachaDelay)

		if State.scriptSettings.GachaTab.AutoGacha and State.scriptSettings.GachaTab.SelectedGacha ~= "" then
			Gacha.autoGachas(State.scriptSettings.GachaTab.SelectedGacha, State.scriptSettings.GachaTab.SelectedTarget)
		end

		if State.scriptSettings.GamemodesTab.AutoFarmMobs then
			Farm.autoFarmEnemies()
		end
	end
end)

task.spawn(function()
	local rewardTimer = 0

	while true do
		local dt = task.wait()

		if State.scriptSettings.PlayerTab.AutoClick then
			autoClickAnimation:SetValue(false)
			Player.autoClicker()
		end

		if State.scriptSettings.PlayerTab.AutoClickAnimation then
			autoClick:SetValue(false)
			Player.autoClickerWithAnimation()
		end

		if State.scriptSettings.GamemodesTab.AutoJoinPublicGamemode then
			Gamemode.autoJoinGamemode(State.gamemodeFold, "Public")
		end

		if State.scriptSettings.GamemodesTab.AutoJoinSelectedGamemode then
			Gamemode.autoJoinGamemode(State.gamemodeFold, "Private")
		end

		if State.scriptSettings.GamemodesTab.AutoLeaveGamemode then
			Gamemode.autoLeaveGamemode()
		end

		Gamemode.gamemodeNotifier(Fluent)

		rewardTimer += dt
		if rewardTimer >= 1 then
			rewardTimer = 0

			if State.scriptSettings.GamemodesTab.AutoCreateGamemode then
				Gamemode.autoCreateGamemodes()
			end

			if State.scriptSettings.PlayerTab.AutoRewards then
				Rewards.autoRewards()
			end

			if State.scriptSettings.PlayerTab.AutoAscension then
				Player.autoAscension()
			end

			if State.scriptSettings.PlayerTab.AutoAchievements then
				Rewards.autoAchievements()
			end

			if State.scriptSettings.PlayerTab.AutoChests then
				Rewards.autoChests()
			end

			changeDescriptionAscension()
			changeDescriptionPlayerStatus()
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(600)
		local character = LocalPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.Jump = true
			end
		end
	end
end)
