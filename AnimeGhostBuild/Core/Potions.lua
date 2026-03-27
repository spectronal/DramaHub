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

function Potions.PotionsMode(mode: "UnPause" | "Pause")
	if mode == "Pause" then
		if LocalPlayer:GetAttribute("InMode") then
			for potions, _ in State.scriptSettings.PotionsTab.SelectedPotionsToPauseInMode or {} do
				print("SelectedPotionsToPauseInMode: " .. State.scriptSettings.PotionsTab.SelectedPotionsToPauseInMode)
				if Framework.PlayerData.PotionPaused[tostring(potions)] == false then
					Framework.Remote:Fire("PotionSystem", "Pause", potions)
				end
			end
		else
			for potions, _ in State.scriptSettings.PotionsTab.SelectedPotionsToPauseNoMode or {} do
				print("SelectedPotionsToPauseNoMode: " .. State.scriptSettings.PotionsTab.SelectedPotionsToPauseNoMode)
				if Framework.PlayerData.PotionPaused[tostring(potions)] == false then
					Framework.Remote:Fire("PotionSystem", "Pause", potions)
				end
			end
		end
	elseif mode == "UnPause" then
		if LocalPlayer:GetAttribute("InMode") then
			print("SelectedPotionsToUnpauseInMode: " .. State.scriptSettings.PotionsTab.SelectedPotionsToUnpauseInMode)
			for potions, _ in State.scriptSettings.PotionsTab.SelectedPotionsToUnpauseInMode or {} do
				if Framework.PlayerData.PotionPaused[tostring(potions)] == true then
					Framework.Remote:Fire("PotionSystem", "Pause", potions)
				end
			end
		else
			for potions, _ in State.scriptSettings.PotionsTab.SelectedPotionsToUnpauseNoMode or {} do
				print(
					"SelectedPotionsToUnpauseNoMode: " .. State.scriptSettings.PotionsTab.SelectedPotionsToUnpauseNoMode
				)
				if Framework.PlayerData.PotionPaused[tostring(potions)] == true then
					Framework.Remote:Fire("PotionSystem", "Pause", potions)
				end
			end
		end
	end
end
