getgenv().DH = getgenv().DH or {}
getgenv().DH.UI = getgenv().DH.UI or {}
getgenv().DH.UI.Potions = {}

local UIPotions = getgenv().DH.UI.Potions
local State = getgenv().DH.State

function UIPotions.build(Tabs)
	local autouse = Tabs.Potion:AddSection("Auto Use")

	local autoUsePotions = autouse:AddDropdown("selectPotions", {
		Title = "Select Potions",
		Values = State.Potions,
		Multi = true,
		Default = 1,
	})

	autouse:AddInput("intervalToUsePotion", {
		Title = "Interval to Use",
		Default = 0,
		Placeholder = "e.g 1 Min = 60 seconds",
		Numeric = true,
		Finished = true,
		Callback = function(Value)
			State.scriptSettings.PotionsTab.IntervalToUse = Value
		end,
	})

	autouse:AddToggle("autoUsePotions", {
		Title = "Auto Use Potions",
		Default = false,
		Callback = function(state)
			State.scriptSettings.PotionsTabs.AutoUsePotions = state
		end,
	})

	local potionsSection = Tabs.Potions:AddSection("Potions")

	local potionsToPauseInMode = potionsSection:AddDropdown("potionsToPauseInMode", {
		Title = "Potions to Pause (On Mode)",
		Values = { "Energy", "Ghost", "Damage", "Luck", "Drop" },
		Multi = true,
		Default = 1,
	})

	local potionsToPauseNoMode = potionsSection:AddDropdown("potionsToPauseNoMode", {
		Title = "Potions to Pause (Off Mode)",
		Values = { "Energy", "Ghost", "Damage", "Luck", "Drop" },
		Multi = true,
		Default = 1,
	})

	potionsSection:AddToggle("autoPausePotions", {
		Title = "Auto Pause Potions",
		Default = false,
		Callback = function(state)
			State.scriptSettings.PotionsTab.AutoPausePotions = state
		end,
	})

	local unpotionsSection = Tabs.Potion:AddSection("")

	local potionsToUnPauseInMode = unpotionsSection:AddDropdown("potionsToUnPauseInMode", {
		Title = "Potions to UnPause (On Mode)",
		Values = { "Energy", "Ghost", "Damage", "Luck", "Drop" },
		Multi = true,
		Default = 1,
	})

	local potionsToUnPauseNoMode = unpotionsSection:AddDropdown("potionsToUnPauseNoMode", {
		Title = "Potions to UnPause (Off Mode)",
		Values = { "Energy", "Ghost", "Damage", "Luck", "Drop" },
		Multi = true,
		Default = 1,
	})

	unpotionsSection:AddToggle("autoUnPausePotions", {
		Title = "Auto UnPause Potions",
		Default = false,
		Callback = function(state)
			State.scriptSettings.PotionsTab.AutoUnPausePotions = state
		end,
	})

	autoUsePotions:OnChanged(function(Value)
		State.scriptSettings.PotionsTab.SelectedPotionsToUse = Value
	end)

	potionsToPauseInMode:OnChanged(function(Value)
		State.scriptSettings.PotionsTab.SelectedPotionsToPauseInMode = Value
	end)

	potionsToPauseNoMode:OnChanged(function(Value)
		State.scriptSettings.PotionsTab.SelectedPotionsToPauseNoMode = Value
	end)

	potionsToUnPauseInMode:OnChanged(function(Value)
		State.scriptSettings.PotionsTab.SelectedPotionsToUnPauseInMode = Value
	end)

	potionsToUnPauseNoMode:OnChanged(function(Value)
		State.scriptSettings.PotionsTab.SelectedPotionsToUnPauseNoMode = Value
	end)
end
