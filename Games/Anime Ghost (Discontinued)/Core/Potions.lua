getgenv().DH = getgenv().DH or {}
getgenv().DH.Potions = {}

local Potions = getgenv().DH.Potions
local State = getgenv().DH.State

local LocalPlayer = game:GetService("Players").LocalPlayer
local Framework = State.Framework

function Potions.AutoUse()
	for i, potions in State.scriptSettings.PotionsTab.SelectedPotionsToUse do
		Framework.Remote:Fire("ItemSystem", "Use", i)
	end
end

function Potions.Pause()
	if LocalPlayer:GetAttribute("InMode") then
		for potions, _ in State.scriptSettings.PotionsTab.SelectedPotionsToPauseInMode or {} do
			if Framework.PlayerData.PotionPaused[tostring(potions)] == false then
				Framework.Remote:Fire("PotionSystem", "Pause", potions)
			end
		end
	else
		for potions, _ in State.scriptSettings.PotionsTab.SelectedPotionsToPauseNoMode or {} do
			if Framework.PlayerData.PotionPaused[tostring(potions)] == false then
				Framework.Remote:Fire("PotionSystem", "Pause", potions)
			end
		end
	end
end

function Potions.UnPause()
	if LocalPlayer:GetAttribute("InMode") then
		for potions, _ in State.scriptSettings.PotionsTab.SelectedPotionsToUnPauseInMode or {} do
			if Framework.PlayerData.PotionPaused[tostring(potions)] == true then
				Framework.Remote:Fire("PotionSystem", "Pause", potions)
			end
		end
	else
		for potions, _ in State.scriptSettings.PotionsTab.SelectedPotionsToUnPauseNoMode or {} do
			if Framework.PlayerData.PotionPaused[tostring(potions)] == true then
				Framework.Remote:Fire("PotionSystem", "Pause", potions)
			end
		end
	end
end
