-- UI/Player.lua
-- Tab: Player

getgenv().DH = getgenv().DH or {}
getgenv().DH.UI = getgenv().DH.UI or {}
getgenv().DH.UI.Player = {}

local UIPlayer = getgenv().DH.UI.Player

function UIPlayer.build(Tabs)
	local State = getgenv().DH.State
	local Player = getgenv().DH.Player

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

	mainPlayer:AddToggle("AutoAscencion", {
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

	-- Expõe os toggles pro Main.lua poder chamar :SetValue()
	getgenv().DH.UI.Player.autoClickAnimation = autoClickAnimation
	getgenv().DH.UI.Player.autoClick = autoClick
end
