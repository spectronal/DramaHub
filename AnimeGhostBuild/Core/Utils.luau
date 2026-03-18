return function(Shared)
	local module = {}

	function module.GetRoot()
		return workspace._CHARACTERS[Shared.LocalPlayer.Name].HumanoidRootPart
	end

	function module.FormatTime(sec)
		local m = math.floor(sec / 60)
		local s = sec % 60
		return string.format("%02dm%02ds", m, s)
	end

	function module.IsAlive(obj)
		return obj and obj.Parent
	end

	return module
end
