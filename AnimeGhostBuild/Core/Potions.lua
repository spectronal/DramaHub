getgenv().DH = getgenv().DH or {}
getgenv().DH.Potions = {}

local Potions = getgenv().DH.Potions
local State = getgenv().DH.State

local LocalPlayer = game:GetService("Players").LocalPlayer

local PotionsUI = LocalPlayer.PlayerGui.Utils.Content.PlayerBoosts
local Framework = State.Framework

function Potions.AutoUse()
	for _, potions in State.scriptSettings.PotionsTab.SelectedPotionsToUse do
		Framework.Remote:Fire("ItemSystem", "Use", potions)
		task.wait((State.scriptSettings.PotionsTab.IntervalToUse or 5))
	end
end

function Potions.PotionsMode(mode: "UnPause" | "Pause")
	if mode == "Pause" then
		if LocalPlayer:GetAttribute("InMode") then
			for _, potions in State.scriptSettings.PotionsTab.SelectedPotionsToPauseInMode do
				if PotionsUI[potions].Timer.Text ~= "Paused" then
					Framework.Remote:Fire("PotionSystem", "Pause", potions)
				end
			end
		else
			for _, potions in State.scriptSettings.PotionsTab.SelectedPotionsToPauseNoMode do
				if PotionsUI[potions].Timer.Text ~= "Paused" then
					Framework.Remote:Fire("PotionSystem", "Pause", potions)
				end
			end
		end
	else
		if LocalPlayer:GetAttribute("InMode") then
			for _, potions in State.scriptSettings.PotionsTab.SelectedPotionsToUnpauseInMode do
				if PotionsUI[potions].Timer.Text == "Paused" then
					Framework.Remote:Fire("PotionSystem", "Pause", potions)
				end
			end
		else
			for _, potions in State.scriptSettings.PotionsTab.SelectedPotionsToUnpauseNoMode do
				if PotionsUI[potions].Timer.Text == "Paused" then
					Framework.Remote:Fire("PotionSystem", "Pause", potions)
				end
			end
		end
	end
end
