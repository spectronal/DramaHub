-- UI/Gamemode.lua
-- Tab: Gamemodes

getgenv().DH = getgenv().DH or {}
getgenv().DH.UI = getgenv().DH.UI or {}
getgenv().DH.UI.Gamemode = {}

local UIGamemode = getgenv().DH.UI.Gamemode

function UIGamemode.build(Tabs, Fluent)
	local State = getgenv().DH.State
	local Gamemode = getgenv().DH.Gamemode
	local Player = getgenv().DH.Player
	local Players = game:GetService("Players")

	-- Main
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
		Default = { "" },
	})

	local selectPriority = mainGamemode:AddDropdown("selectPriority", {
		Title = "Priority",
		Description = "Note: It may contain bugs based on your Enemy Range",
		Values = { "Weakest > Strongest", "Strongest > Weakest" },
		Multi = false,
		Default = 1,
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
		Title = "Raid Map",
		Description = "Select an raid map",
		Values = State.RaidData,
		Multi = false,
		Default = "Choose an raid map",
	})

	local selectDungeon = mapsGamemode:AddDropdown("selectDungeon", {
		Title = "Dungeon Map",
		Description = "Select an dungeon map",
		Values = State.DungeonData,
		Multi = false,
		Default = "Choose an dungeon map",
	})

	local selectInfinity = mapsGamemode:AddDropdown("selectInfinity", {
		Title = "Infinity Castle Map",
		Description = "Select an infinity map",
		Values = State.InfinityData,
		Multi = false,
		Default = "Choose an infinity map",
	})

	local selectDefense = mapsGamemode:AddDropdown("selectDefense", {
		Title = "Defense Mode Map",
		Description = "Select an Defense map",
		Values = State.DefenseData,
		Multi = false,
		Default = "Choose an defense map",
	})

	-- Difficulties
	local diffGamemode = Tabs.Gamemode:AddSection("Difficulties")

	local selectRaidDiff = diffGamemode:AddDropdown("selectRaidDiff", {
		Title = "Raid Diff",
		Description = "Select a difficulty for raids",
		Values = { "Easy" },
		Multi = false,
		Default = "",
	})

	local selectDungeonDiff = diffGamemode:AddDropdown("selectDungeonDiff", {
		Title = "Dungeon Diff",
		Description = "Select a difficulty for dungeons",
		Values = { "Easy", "Medium", "Hard" },
		Multi = false,
		Default = "",
	})

	local selectInfinityDiff = diffGamemode:AddDropdown("selectInfinityDiff", {
		Title = "Infinity Diff",
		Description = "Select a difficulty for infinity castle",
		Values = { "Easy" },
		Multi = false,
		Default = "",
	})

	local selectDefenseDiff = diffGamemode:AddDropdown("selectDefenseDiff", {
		Title = "Defense Diff",
		Description = "Select a difficulty for defense mode",
		Values = { "Easy" },
		Multi = false,
		Default = "",
	})

	-- Leave In
	local leaveGamemode = Tabs.Gamemode:AddSection("Leave in")

	leaveGamemode:AddParagraph({
		Title = "Note:",
		Content = "Press enter for each input to confirm",
	})

	leaveGamemode:AddInput("raidLeaveIn", {
		Title = "Raid Leave at",
		Default = 0,
		Placeholder = "e.g 30",
		Numeric = true,
		Finished = true,
		Callback = function(Value)
			State.scriptSettings.GamemodesTab.RaidToLeave = Value
		end,
	})

	leaveGamemode:AddInput("dungeonLeaveIn", {
		Title = "Dungeon Leave at",
		Default = 0,
		Placeholder = "e.g 30",
		Numeric = true,
		Finished = true,
		Callback = function(Value)
			State.scriptSettings.GamemodesTab.DungeonToLeave = Value
		end,
	})

	leaveGamemode:AddInput("infinityLeaveIn", {
		Title = "Infinity Leave at",
		Default = 0,
		Placeholder = "e.g 30",
		Numeric = true,
		Finished = true,
		Callback = function(Value)
			State.scriptSettings.GamemodesTab.InfinityCastleToLeave = Value
		end,
	})

	leaveGamemode:AddInput("defenseModeLeaveIn", {
		Title = "Defense Leave at",
		Default = 0,
		Placeholder = "e.g 30",
		Numeric = true,
		Finished = true,
		Callback = function(Value)
			State.scriptSettings.GamemodesTab.DefenseModeToLeave = Value
		end,
	})

	--[[	leaveGamemode:AddToggle("autoLeave", {
		Title = "Auto Leave Gamemode",
		Default = false,
		Callback = function(state)
			State.scriptSettings.GamemodesTab.AutoLeaveGamemode = state
		end,
	})]]

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

	-- Players to Join
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

	-- Equip Best
	local equipbestSection = Tabs.Gamemode:AddSection("Equip Best")

	local equipBestinMode = equipbestSection:AddDropdown("equipBestinMode", {
		Title = "Equip Best (On Mode)",
		Values = { "Energy", "Damage", "Ghost", "EggLuck", "AtkSPD", "GachaLuck", "Drop" },
		Multi = false,
		Default = 1,
	})

	local equipBest = equipbestSection:AddDropdown("equipBest", {
		Title = "Equip Best (Off Mode)",
		Values = { "Energy", "Damage", "Ghost", "EggLuck", "AtkSPD", "GachaLuck", "Drop" },
		Multi = false,
		Default = 1,
	})

	equipbestSection:AddToggle("autoEquipBest", {
		Title = "Auto Equip Best",
		Default = false,
		Callback = function(state)
			State.scriptSettings.GamemodesTab.AutoEquipBest = state
		end,
	})

	local titlesSection = Tabs.Gamemode:AddSection("Titles")

	local equipTitleInMode = titlesSection:AddDropdown("equipTitleInMode", {
		Title = "Equip Title (On Mode)",
		Values = State.Titles,
		Multi = false,
		Default = 1,
	})

	local equipTitle = titlesSection:AddDropdown("equipTitle", {
		Title = "Equip Title (Off Mode)",
		Values = State.Titles,
		Multi = false,
		Default = 1,
	})

	titlesSection:AddButton({
		Title = "Refresh Titles",
		Callback = function()
			table.clear(State.Titles)

			for titles, v in pairs(State.Framework.PlayerData.Titles) do
				table.insert(State.Titles, titles)
			end

			equipTitleInMode:SetValue(State.Titles)
			equipTitle:SetValue(State.Titles)
		end,
	})

	titlesSection:AddToggle("autoEquipTitle", {
		Title = "Auto Equip Titles",
		Default = false,
		Callback = function(state)
			State.scriptSettings.GamemodesTab.AutoEquipTitle = state
		end,
	})

	-- OnChanged Handlers do

	selectGamemode:OnChanged(function(Value)
		State.scriptSettings.GamemodesTab.SelectedGamemode = Value
	end)

	selectPriority:OnChanged(function(Value)
		State.scriptSettings.GamemodesTab.SelectedPriority = Value
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

	selectDefense:OnChanged(function(Value)
		State.scriptSettings.GamemodesTab.SelectedDefenseMode = Value
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

	selectDefenseDiff:OnChanged(function(Value)
		State.scriptSettings.GamemodesTab.SelectedDefenseModeDifficulty = Value
	end)

	selectPlayersToJoin:OnChanged(function(Value)
		State.scriptSettings.GamemodesTab.SelectedPlayersToJoin = Value
	end)

	saveWorldToTp:OnChanged(function(Value)
		State.scriptSettings.GamemodesTab.WorldToTeleport = Value
	end)

	equipBestinMode:OnChanged(function(Value)
		State.scriptSettings.GamemodesTab.SelectedEquipBestInMode = Value
	end)

	equipBest:OnChanged(function(Value)
		State.scriptSettings.GamemodesTab.SelectedEquipBestNoMode = Value
	end)

	equipTitleInMode:OnChanged(function(Value)
		State.scriptSettings.GamemodesTab.SelectedEquipTitleInMode = Value
	end)

	equipTitle:OnChanged(function(Value)
		State.scriptSettings.GamemodesTab.SelectedEquipTitleNoMode = Value
	end)
end
