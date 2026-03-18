return function(Shared)
	local module = {}

	local state = Shared.State
	local Framework = Shared.Framework

	function module.RunSecond()
		if state.Settings.PlayerTab.AutoRewards then
			Framework.Remote:Fire("RewardSystem", "ClaimAll")
		end

		if state.Settings.PlayerTab.AutoAchievments then
			Framework.Remote:Fire("AchievementSystem", "ClaimAll")
		end

		if state.Settings.PlayerTab.AutoChests then
			Framework.Remote:Fire("ChestSystem", "ClaimAll")
		end
	end

	return module
end
