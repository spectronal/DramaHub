return function(Shared)
	local module = {}

	local state = Shared.State
	local Framework = Shared.Framework

	function module.Run()
		if state.Settings.PlayerTab.AutoClick then
			Framework.Remote:Fire("ClickSystem", "Execute", Framework.Target)
		end

		if state.Settings.PlayerTab.AutoAscension then
			Framework.Remote:Fire("AscensionSystem", "Ascend")
		end
	end

	return module
end
