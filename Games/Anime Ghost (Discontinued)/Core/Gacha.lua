getgenv().DH = getgenv().DH or {}
getgenv().DH.Gacha = {}

local Gacha = getgenv().DH.Gacha
local State = getgenv().DH.State

local Framework = State.Framework
local Notify = State.Notify

function Gacha.autoGachas(gachaId, Target)
	for i, v in pairs(Target) do
		if Framework.PlayerData.GachaIndex[gachaId][v] then
			Notify("<dr> [Drama Hub] </>" .. "<w> You already have " .. v .. " Target! </>")
			return
		end

		Framework.Remote:Fire("GachaSystem", "Spin", gachaId, "Normal", {}, v)

		if Framework.PlayerData.GachaIndex[gachaId][v] then
			Notify("<dr> [Drama Hub] </>" .. "<w> You got " .. v .. " Target! </>")
		end
	end
end

function Gacha.removeGachaAnimation()
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
