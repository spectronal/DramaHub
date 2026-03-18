return function(Shared)
	local State = Shared.State

	local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/source.lua"))()
	local SaveManager =
		loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/addons/SaveManager.lua"))()
	local InterfaceManager = loadstring(
		game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/addons/InterfaceManager.lua")
	)()

	local Window = Fluent:CreateWindow({
		Title = "Drama Hub",
		SubTitle = "Anime Ghost",
		TabWidth = 160,
		Size = UDim2.fromOffset(580, 460),
		Acrylic = true,
		Theme = "Dark",
		MinimizeKey = Enum.KeyCode.LeftControl,
	})

	-- TABS
	local Tabs = {
		Player = Window:AddTab({ Title = "Player", Icon = "user" }),
		Gacha = Window:AddTab({ Title = "Gacha", Icon = "shuffle" }),
		Gamemodes = Window:AddTab({ Title = "Gamemodes", Icon = "swords" }),
	}

	-- =========================
	-- PLAYER TAB
	-- =========================

	Tabs.Player:AddToggle("AutoClick", {
		Title = "Auto Click",
		Default = false,
		Callback = function(v)
			State.Settings.PlayerTab.AutoClick = v
		end,
	})

	Tabs.Player:AddToggle("AutoAscension", {
		Title = "Auto Ascension",
		Default = false,
		Callback = function(v)
			State.Settings.PlayerTab.AutoAscension = v
		end,
	})

	Tabs.Player:AddToggle("AutoRewards", {
		Title = "Auto Rewards",
		Default = false,
		Callback = function(v)
			State.Settings.PlayerTab.AutoRewards = v
		end,
	})

	Tabs.Player:AddToggle("AutoAchievements", {
		Title = "Auto Achievements",
		Default = false,
		Callback = function(v)
			State.Settings.PlayerTab.AutoAchievments = v
		end,
	})

	Tabs.Player:AddToggle("AutoChests", {
		Title = "Auto Chests",
		Default = false,
		Callback = function(v)
			State.Settings.PlayerTab.AutoChests = v
		end,
	})

	-- =========================
	-- GACHA TAB
	-- =========================

	Tabs.Gacha:AddInput("SelectedGacha", {
		Title = "Gacha Name",
		Default = "",
		Callback = function(v)
			State.Settings.GachaTab.SelectedGacha = v
		end,
	})

	Tabs.Gacha:AddInput("TargetUnit", {
		Title = "Target Unit",
		Default = "",
		Callback = function(v)
			State.Settings.GachaTab.SelectedTarget = { v }
		end,
	})

	Tabs.Gacha:AddSlider("GachaDelay", {
		Title = "Delay",
		Default = 0.1,
		Min = 0,
		Max = 2,
		Rounding = 2,
		Callback = function(v)
			State.Settings.GachaTab.GachaDelay = v
		end,
	})

	Tabs.Gacha:AddToggle("AutoGacha", {
		Title = "Auto Gacha",
		Default = false,
		Callback = function(v)
			State.Settings.GachaTab.AutoGacha = v
		end,
	})

	-- =========================
	-- GAMEMODES TAB
	-- =========================

	Tabs.Gamemodes:AddToggle("AutoFarmMobs", {
		Title = "Auto Farm Mobs",
		Default = false,
		Callback = function(v)
			State.Settings.GamemodesTab.AutoFarmMobs = v
		end,
	})

	Tabs.Gamemodes:AddToggle("AutoCreate", {
		Title = "Auto Create Gamemode",
		Default = false,
		Callback = function(v)
			State.Settings.GamemodesTab.AutoCreateGamemode = v
		end,
	})

	Tabs.Gamemodes:AddToggle("AutoLeave", {
		Title = "Auto Leave",
		Default = false,
		Callback = function(v)
			State.Settings.GamemodesTab.AutoLeaveGamemode = v
		end,
	})

	-- PRIORIDADE GAMEMODES

	Tabs.Gamemodes:AddToggle("Raid", {
		Title = "Raid",
		Default = false,
		Callback = function(v)
			State.Settings.GamemodesTab.SelectedGamemode["Raid"] = v
		end,
	})

	Tabs.Gamemodes:AddToggle("Dungeon", {
		Title = "Dungeon",
		Default = false,
		Callback = function(v)
			State.Settings.GamemodesTab.SelectedGamemode["Dungeon"] = v
		end,
	})

	Tabs.Gamemodes:AddToggle("InfinityCastle", {
		Title = "Infinity Castle",
		Default = false,
		Callback = function(v)
			State.Settings.GamemodesTab.SelectedGamemode["Infinity Castle"] = v
		end,
	})

	-- =========================
	-- SAVE SYSTEM
	-- =========================

	SaveManager:SetLibrary(Fluent)
	InterfaceManager:SetLibrary(Fluent)

	SaveManager:IgnoreThemeSettings()
	SaveManager:SetIgnoreIndexes({})

	InterfaceManager:SetFolder("DramaHub")
	SaveManager:SetFolder("DramaHub/AnimeGhost")

	SaveManager:BuildConfigSection(Tabs.Player)
	InterfaceManager:BuildInterfaceSection(Tabs.Player)

	Window:SelectTab(1)

	return Window
end
