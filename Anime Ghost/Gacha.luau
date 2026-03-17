local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Framework = require(replicatedStorage.Framework.Library)
local Abbreviate = Framework:GetService("AbbreviateService")
local MultiplierSe
rvice = Framework:GetService("MultiplierService")
local DebounceService = Framework:GetService("DebounceService")
local AnimationService = Framework:GetService("AnimationService")

local GachaData = Framework:GetData("GachaData")

-- Gacha
local Gachas = {}
local Targets = {}

for id in pairs(GachaData) do
	table.insert(Gachas, id)
end

local function autoGachas(Gacha: string, Target)
	Framework.Remote:Fire("GachaSystem", "Spin", Gacha, "Normal", {}, Target)
end

local function removeGachaAnimation()
	local mod = require(Framework.Modules.Services.GachaService)

	mod.SetupAnimation = function()
		return
	end
	mod.QuitAnimation = function()
		return
	end
	mod.StartAnimation = function()
		return
	end
end
