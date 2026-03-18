getgenv().DH = getgenv().DH or {}
getgenv().DH.Gacha = {}

local Gacha = getgenv().DH.Gacha
local State = getgenv().DH.State

local Framework = State.Framework

function Gacha.autoGachas(gachaId, Target)
	Framework.Remote:Fire("GachaSystem", "Spin", gachaId, "Normal", {}, Target)
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
