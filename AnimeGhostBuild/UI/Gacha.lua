-- UI/Gacha.lua
-- Tab: Gachas

getgenv().DH = getgenv().DH or {}
getgenv().DH.UI = getgenv().DH.UI or {}
getgenv().DH.UI.Gacha = {}

local UIGacha = getgenv().DH.UI.Gacha

function UIGacha.build(Tabs)
	local State = getgenv().DH.State
	local Gacha = getgenv().DH.Gacha

	local mainGacha = Tabs.Gachas:AddSection("Main")
	mainGacha:AddParagraph({
		Title   = "Gacha Features",
		Content = "\nHere you can find various features related to gacha mechanics.",
	})

	local selectGacha = mainGacha:AddDropdown("selectGacha", {
		Title       = "Select Gacha",
		Description = "Select a gacha to spin",
		Values      = State.Gachas,
		Multi       = false,
		Default     = "Psychic Power",
	})

	local selectGachaTarget = mainGacha:AddDropdown("selectGachaTarget", {
		Title       = "Select Target",
		Description = "Select your target for spin",
		Values      = State.Targets,
		Multi       = true,
		Default     = { "Choose a target" },
	})

	mainGacha:AddToggle("autoGacha", {
		Title    = "Auto Gacha",
		Default  = false,
		Callback = function(state)
			State.scriptSettings.GachaTab.AutoGacha = state
		end,
	})

	local gachaSettings = Tabs.Gachas:AddSection("Settings")

	gachaSettings:AddSlider("gachaDelay", {
		Title       = "Spin Delay",
		Description = "Set the delay between each spin (in seconds)",
		Default     = 0.1,
		Min         = 0.1,
		Max         = 5,
		Rounding    = 0.1,
		Callback    = function(Value)
			State.scriptSettings.GachaTab.GachaDelay = Value
		end,
	})

	gachaSettings:AddButton({
		Title    = "Remove Gacha Animation",
		Callback = function()
			Gacha.removeGachaAnimation()
		end,
	})

	-- OnChanged
	selectGacha:OnChanged(function(Value)
		table.clear(State.Targets)
		State.scriptSettings.GachaTab.SelectedGacha = Value

		for targetId in pairs(State.GachaData[Value].Targets) do
			if not table.find(State.Targets, targetId) then
				table.insert(State.Targets, targetId)
			end
		end

		selectGachaTarget:SetValue(State.Targets)
	end)

	selectGachaTarget:OnChanged(function(Value)
		State.scriptSettings.GachaTab.SelectedTarget = Value
	end)
end
