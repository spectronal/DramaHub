<<<<<<< HEAD
=======
-- Core/Player.lua
-- Auto Click, Auto Ascension, Cutscene removal, Descriptions
-- Loaded via: loadstring(game:HttpGet(URL))()

>>>>>>> a7c92498be86213c075e5800ff42019ea1fb1cb4
getgenv().DH = getgenv().DH or {}
getgenv().DH.Player = {}

local Player = getgenv().DH.Player
local State = getgenv().DH.State

local replicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Framework = State.Framework
local MultiplierService = Framework:GetService("MultiplierService")
local DebounceService = Framework:GetService("DebounceService")
local AnimationService = Framework:GetService("AnimationService")

<<<<<<< HEAD
-- Auto Clicker
=======
-- ════════════════════════════════════════
-- Auto Clicker
-- ════════════════════════════════════════
>>>>>>> a7c92498be86213c075e5800ff42019ea1fb1cb4

function Player.autoClicker()
	Framework.Remote:Fire("ClickSystem", "Execute", Framework.Target)
end

function Player.autoClickerWithAnimation()
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
		State.comboIndex += 1

		if tick() - State.lastClickTime > 2 then
			State.comboIndex = 1
		end

		if State.comboIndex > 3 then
			State.comboIndex = 1
		end

		State.lastClickTime = tick()

		local animationType = "Punch"

		if not Framework.PlayerData.Settings.HideWeapon then
			local weaponTypes = { "Weapon", "DualWeapon", "TripleWeapon" }
			local equipped = #Framework.PlayerData.WeaponsEquipped

			if equipped > 0 then
				animationType = weaponTypes[equipped]
			end
		end

		if not Framework.LocalPlayer:GetAttribute("OnMount") then
			AnimationService.Load(
				Framework.LocalPlayer.Character.Humanoid.Animator,
				("%s %s"):format(animationType, State.comboIndex),
				animationSpeed,
				"Action2"
			)
		end
	end
end

<<<<<<< HEAD
-- Auto Ascension
=======
-- ════════════════════════════════════════
-- Auto Ascension
-- ════════════════════════════════════════
>>>>>>> a7c92498be86213c075e5800ff42019ea1fb1cb4

function Player.autoAscension()
	for key, level in pairs(Framework.PlayerData.Rebirth) do
		local id, type = key:match("(.+)_(.+)")
		local rebirthType = State.RebirthData[id].Types[type]

		local nextLevel = level + 1
		local levelData = rebirthType.Levels[nextLevel]

		if levelData then
			local currency = rebirthType.Currency
			local playerMoney = Framework.PlayerData[currency]
			local price = levelData.Price

			if playerMoney >= price then
				Framework.Remote:Fire("RebirthSystem", "Release", id, type)
			end
		end
	end
end

function Player.removeCutscene()
	local oldRequire = require

	require = function(module)
		if module == Framework.Modules.Client.Controllers.CutsceneController.Ascension then
			return function() end
		end

		return oldRequire(module)
	end
end

<<<<<<< HEAD
-- Descriptions
=======
-- ════════════════════════════════════════
-- Descriptions
-- ════════════════════════════════════════
>>>>>>> a7c92498be86213c075e5800ff42019ea1fb1cb4

function Player.registerDescriptions()
	for _, obj in ipairs(LocalPlayer.PlayerGui:WaitForChild("DramaHub"):GetDescendants()) do
		if obj:IsA("TextLabel") then
			if obj.Text:find("Calculing...") then
				obj.Name = "AscensionDescription"
				State.Descriptions["Ascension"] = obj
			elseif obj.Text:find("StatusMode") then
				obj.Name = "PlayerStatusDescription"
				State.Descriptions["PlayerStatus"] = obj
			end
		end
	end
end

function Player.setDescription(name, text)
	local label = State.Descriptions[name]
	if label then
		label.Text = text
	end
end
