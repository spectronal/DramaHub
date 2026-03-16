local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local descLabel

local Framework = require(replicatedStorage.Framework.Library)
local Abbreviate = Framework:GetService("AbbreviateService")
local MultiplierService = Framework:GetService("MultiplierService")
local DebounceService = Framework:GetService("DebounceService")
local AnimationService = Framework:GetService("AnimationService")

-- AutoClicker with animation
local lastClickTime = tick()
local comboIndex = 0

local function autoClicker()
	Framework.Remote:Fire("ClickSystem", "Execute", Framework.Target)
end

local function autoClickerWithAnimation()
	if Framework.LocalPlayer:GetAttribute("UsingSkill") then
		return
	end

	if DebounceService.Check(Framework.LocalPlayer, "Click", 0.05) then
		return
	end

	Framework.Remote:Fire("ClickSystem", "Execute", Framework.Target)

	local atkSpeed = MultiplierService.AtkSPD(Framework.LocalPlayer)
	local animationSpeed = 0.6 / atkSpeed

	if not DebounceService.Check(Framework.LocalPlayer, "ClickAnimation", atkSpeed * 1.1) then
		-- combo system
		comboIndex += 1

		if tick() - lastClickTime > 2 then
			comboIndex = 1
		end

		if comboIndex > 3 then
			comboIndex = 1
		end

		lastClickTime = tick()

		local animationType = "Punch"

		if not Framework.PlayerData.Settings.HideWeapon then
			local weaponTypes = {
				"Weapon",
				"DualWeapon",
				"TripleWeapon",
			}

			local equipped = #Framework.PlayerData.WeaponsEquipped

			if equipped > 0 then
				animationType = weaponTypes[equipped]
			end
		end

		if not Framework.LocalPlayer:GetAttribute("OnMount") then
			AnimationService.Load(
				Framework.LocalPlayer.Character.Humanoid.Animator,
				("%s %s"):format(animationType, comboIndex),
				animationSpeed,
				"Action2"
			)
		end
	end
end
