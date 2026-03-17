-- UI

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")
)()

coreGui:FindFirstChild("ScreenGui").Name = "FluentUI"

LocalPlayer:GetAttributeChangedSignal("Mode"):Connect(function()
	local mode = LocalPlayer:GetAttribute("Mode")
	local ownerId = Players[playerNameFromId].UserId

	if not mode or mode == "" then
		Fluent:Notify({
			Title = "Gamemode System ",
			Content = "You left the gamemode",
			Duration = 3,
		})
		return
	end

	if ownerId == LocalPlayer.UserId then
		Fluent:Notify({
			Title = "Gamemode System",
			Content = "You created a " .. mode .. " gamemode",
			Duration = 3,
		})
	else
		Fluent:Notify({
			Title = "Gamemode System",
			Content = "Joined " .. playerNameFromId .. "'s " .. mode,
			Duration = 3,
		})
	end
end)

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

local diffGamemode = Tabs.Gamemode:AddSection("Difficulties")

local selectRaidDiff = diffGamemode:AddDropdown("selectRaidDiff", {
	Title = "Select Raid Difficulty",
	Description = "Select a difficulty for raids",
	Values = { "Easy", "Medium", "Hard" },
	Multi = false,
	Default = "",
})

local selectDungeonDiff = diffGamemode:AddDropdown("selectDungeonDiff", {
	Title = "Select Dungeon Difficulty",
	Description = "Select a difficulty for dungeons",
	Values = { "Easy", "Medium", "Hard" },
	Multi = false,
	Default = "",
})

local selectInfinityDiff = diffGamemode:AddDropdown("selectInfinityDiff", {
	Title = "Select Infinity Difficulty",
	Description = "Select a difficulty for infinity castle",
	Values = { "Easy" },
	Multi = false,
	Default = "",
})

local leaveGamemode = Tabs.Gamemode:AddSection("Leave in")

local raidLeaveIn = leaveGamemode:AddInput("raidLeaveIn", {
	Title = "Raid Leave In",
	Default = 0,
	Placeholder = "e.g 30",
	Numeric = true,
	Finished = false,
	Callback = function(Value)
		scriptSettings.GamemodesTab.RaidToLeave = Value
	end,
})

local dungeonLeaveIn = leaveGamemode:AddInput("dungeonLeaveIn", {
	Title = "Dungeon Leave In",
	Default = 0,
	Placeholder = "e.g 30",
	Numeric = true,
	Finished = false,
	Callback = function(Value)
		scriptSettings.GamemodesTab.DungeonToLeave = Value
	end,
})

local infinityLeaveIn = leaveGamemode:AddInput("infinityLeaveIn", {
	Title = "Infinity Leave In",
	Default = 0,
	Placeholder = "e.g 30",
	Numeric = true,
	Finished = false,
	Callback = function(Value)
		scriptSettings.GamemodesTab.InfinityCastleToLeave = Value
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
	Default = {},
})

local refreshPlayers = playerGamemode:AddButton({
	Title = "Refresh Players List",
	Callback = function()
		refreshPlayersList(selectPlayersToJoin)
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

selectGamemode:OnChanged(function(Value)
	scriptSettings.GamemodesTab.SelectedGamemode = Value
end)

-- Diffs

selectInfinityDiff:OnChanged(function(Value)
	scriptSettings.GamemodesTab.SelectedInfinityCastleDifficulty = Value
end)

selectRaidDiff:OnChanged(function(Value)
	scriptSettings.GamemodesTab.SelectedRaidDifficulty = Value
end)

selectDungeonDiff:OnChanged(function(Value)
	scriptSettings.GamemodesTab.SelectedDungeonDifficulty = Value
end)

-- Maps

selectInfinity:OnChanged(function(Value)
	scriptSettings.GamemodesTab.SelectedInfinityCastle = Value
end)

selectRaid:OnChanged(function(Value)
	scriptSettings.GamemodesTab.SelectedRaid = Value
end)

selectDungeon:OnChanged(function(Value)
	scriptSettings.GamemodesTab.SelectedDungeon = Value
end)

selectPlayersToJoin:OnChanged(function(Value)
	scriptSettings.GamemodesTab.SelectedPlayersToJoin = Value
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

		if scriptSettings.GamemodesTab.AutoJoinPublicGamemode then
			autoJoinGamemode(gamemodeFold, "Public")
		end

		if scriptSettings.GamemodesTab.AutoJoinSelectedGamemode then
			autoJoinGamemode(gamemodeFold, "Private")
		end

		rewardTimer += dt
		if rewardTimer >= 1 then
			rewardTimer = 0
			if scriptSettings.GamemodesTab.AutoCreateGamemode then
				print("a")
				autoCreateGamemodes()
			end

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
			--changeDescriptionName()
		end
	end
end)
