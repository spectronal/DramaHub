-- Core/Utils.lua
-- General utility / helper functions
-- Loaded via: loadstring(game:HttpGet(URL))()

getgenv().DH = getgenv().DH or {}
getgenv().DH.Utils = {}

local Utils = getgenv().DH.Utils

function Utils.Color3ToHex(color)
	local r = math.clamp(math.floor(color.R * 255), 0, 255)
	local g = math.clamp(math.floor(color.G * 255), 0, 255)
	local b = math.clamp(math.floor(color.B * 255), 0, 255)
	return string.format("%02X%02X%02X", r, g, b)
end
