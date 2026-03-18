local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

local Framework = require(RS.Framework.Library)

local BASE = "https://raw.githubusercontent.com/spectronal/DramaHub/refs/heads/main/AnimeGhostBuild/"

local function load(path)
	return loadstring(game:HttpGet(BASE .. path))()
end

-- STATE
local State = load("Systems/State.lua")()

local Shared = {
	Framework = Framework,
	LocalPlayer = LocalPlayer,
	State = State,
}

task.spawn(function()
	load("UI/UI.luau")(Shared)
end)

-- MODULES
local Modules = {
	load("Core/Utils.luau")(Shared),
	load("Core/Player.luau")(Shared),
	load("Core/Rewards.luau")(Shared),
	load("Core/Farm.luau")(Shared),
	load("Core/Gamemode.luau")(Shared),
	load("Core/Gacha.luau")(Shared),
}

-- LOOP
task.spawn(function()
	local sec = 0

	while true do
		local dt = task.wait()

		for _, m in ipairs(Modules) do
			if m.Run then
				m.Run(dt)
			end
		end

		sec += dt

		if sec >= 1 then
			sec = 0
			for _, m in ipairs(Modules) do
				if m.RunSecond then
					m.RunSecond()
				end
			end
		end
	end
end)
