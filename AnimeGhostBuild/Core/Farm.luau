return function(Shared)
	local module = {}

	local state = Shared.State
	local Framework = Shared.Framework

	local enemies = workspace._ENEMIES.Server

	local function getMob()
		local list = {}

		for _, mob in pairs(enemies.Gamemode:GetDescendants()) do
			if mob:IsA("Part") and mob:GetAttribute("Order") then
				table.insert(list, mob)
			end
		end

		table.sort(list, function(a, b)
			return a:GetAttribute("Order") < b:GetAttribute("Order")
		end)

		return list[1]
	end

	local function tp(mob)
		if not mob then
			return
		end

		local root = workspace._CHARACTERS[Shared.LocalPlayer.Name].HumanoidRootPart

		if tick() - state.Runtime.lastTeleport > 0.5 then
			root.CFrame = CFrame.new(mob.Position + Vector3.new(0, 6, 0))
			state.Runtime.lastTeleport = tick()
		end
	end

	function module.Run()
		if not state.Settings.GamemodesTab.AutoFarmMobs then
			return
		end

		local mob = state.Runtime.currentMob

		if not mob or not mob.Parent then
			mob = getMob()
			state.Runtime.currentMob = mob
			state.Runtime.lastHP = nil
			state.Runtime.stuckTime = 0
		end

		if not mob then
			return
		end

		tp(mob)

		Framework.Remote:Fire("ClickSystem", "Execute", Framework.Target)

		local hp = mob:GetAttribute("HP")

		if state.Runtime.lastHP then
			if hp == state.Runtime.lastHP then
				state.Runtime.stuckTime += 1
			else
				state.Runtime.stuckTime = 0
			end

			if state.Runtime.stuckTime >= 5 then
				tp(mob)
				state.Runtime.stuckTime = 0
			end
		end

		state.Runtime.lastHP = hp
	end

	return module
end
