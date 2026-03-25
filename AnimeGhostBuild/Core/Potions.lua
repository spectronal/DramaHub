getgenv().DH = getgenv().DH or {}
getgenv().DH.Potions = {}

local Potions = getgenv().DH.Potions
local State = getgenv().DH.State

local LocalPlayer = game:GetService("Players").LocalPlayer

local Framework = State.Framework

function Potions.AutoUse()
	for i, potions in State.scriptSettings.PotionsTab.SelectedPotionsToUse do
		print(i, potions)
		Framework.Remote:Fire("ItemSystem", "Use", i)
		task.wait((State.scriptSettings.PotionsTab.IntervalToUse or 5))
	end
end

function Potions.PotionsMode(mode: "UnPause" | "Pause")
	if mode == "Pause" then
		if LocalPlayer:GetAttribute("InMode") then
			for potions, _ in State.scriptSettings.PotionsTab.SelectedPotionsToPauseInMode or {} do
				if Framework.PlayerData.PotionPaused[potions] == false then
					Framework.Remote:Fire("PotionSystem", "Pause", potions)
				end
			end
		else
			for potions, _ in State.scriptSettings.PotionsTab.SelectedPotionsToPauseNoMode or {} do
				if Framework.PlayerData.PotionPaused[potions] == false then
					Framework.Remote:Fire("PotionSystem", "Pause", potions)
				end
			end
		end
	else
		if LocalPlayer:GetAttribute("InMode") then
			for potions, _ in State.scriptSettings.PotionsTab.SelectedPotionsToUnpauseInMode or {} do
				if Framework.PlayerData.PotionPaused[potions] == true then
					Framework.Remote:Fire("PotionSystem", "Pause", potions)
				end
			end
		else
			for potions, _ in State.scriptSettings.PotionsTab.SelectedPotionsToUnpauseNoMode or {} do
				if Framework.PlayerData.PotionPaused[potions] == true then
					Framework.Remote:Fire("PotionSystem", "Pause", potions)
				end
			end
		end
	end
end
