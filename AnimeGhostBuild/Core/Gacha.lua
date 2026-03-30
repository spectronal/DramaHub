getgenv().DH = getgenv().DH or {}
getgenv().DH.Gacha = {}

local Gacha = getgenv().DH.Gacha
local State = getgenv().DH.State

local Framework = State.Framework
local Notify = State.Notify

function Gacha.autoGachas(gachaId, Target)
	if not Framework.PlayerData.GachaIndex[gachaId][Target] then
		Notify("<dr> [Drama Hub] </>" .. "<w> You already have the " .. Target .. " Target! </>")
		return
	end

	Framework.Remote:Fire("GachaSystem", "Spin", gachaId, "Normal", {}, Target)

	if Framework.PlayerData.GachaIndex[gachaId][Target] then
		Notify("<dr> [Drama Hub] </>" .. "<w> You got " .. Target .. " Target! </>")
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
