return function(Shared)
	local module = {}

	local state = Shared.State
	local Framework = Shared.Framework

	local lastCreate = 0

	local Priority = {
		Raid = 1,
		Dungeon = 2,
		["Infinity Castle"] = 3,
	}

	local function onCooldown(mode)
		return (state.Cooldowns[mode] or 0) > tick()
	end

	function module.RunSecond()
		-- CREATE
		if state.Settings.GamemodesTab.AutoCreateGamemode then
			if tick() - lastCreate < 2 then
				return
			end
			lastCreate = tick()

			local chosen
			local best = math.huge

			for mode, enabled in pairs(state.Settings.GamemodesTab.SelectedGamemode) do
				if enabled and not onCooldown(mode) then
					local p = Priority[mode]
					if p < best then
						best = p
						chosen = mode
					end
				end
			end

			if chosen then
				local key = "Selected" .. string.gsub(chosen, " ", "")
				local diff = key .. "Difficulty"

				Framework.Remote:Fire(
					"GamemodeSystem",
					"Create",
					chosen,
					state.Settings.GamemodesTab[key],
					state.Settings.GamemodesTab[diff]
				)
			end
		end

		-- LEAVE
		if state.Settings.GamemodesTab.AutoLeaveGamemode then
			Framework.Remote:Fire("GamemodeSystem", "Leave")
		end
	end

	return module
end
