return function(Shared)
	local module = {}

	local last = 0

	function module.Run()
		local g = Shared.State.Settings.GachaTab

		if not g.AutoGacha then
			return
		end

		if tick() - last < g.GachaDelay then
			return
		end
		last = tick()

		Shared.Framework.Remote:Fire("GachaSystem", "Spin", g.SelectedGacha, "Normal", {}, g.SelectedTarget)
	end

	return module
end
