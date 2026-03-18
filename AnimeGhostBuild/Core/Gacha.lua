<<<<<<< HEAD
=======
-- Core/Gacha.lua
-- Auto Gacha and gacha animation removal
-- Loaded via: loadstring(game:HttpGet(URL))()

>>>>>>> a7c92498be86213c075e5800ff42019ea1fb1cb4
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
