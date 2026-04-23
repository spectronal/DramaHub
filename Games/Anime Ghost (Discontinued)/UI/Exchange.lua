getgenv().DH = getgenv().DH or {}
getgenv().DH.UI = getgenv().DH.UI or {}
getgenv().DH.UI.Exchange = {}

local UIExchange = getgenv().DH.UI.Exchange

function UIExchange.build(Tabs)
	local State = getgenv().DH.State

	local exchangeSection = Tabs.Exchange:AddSection("Potions")

	local potionsDropdown = exchangeSection:AddDropdown("potionsDropdown", {
		Title = "Select Potion Tiers",
		Description = "Note: Tier 3 > Tier 4 wasnt released for exchange yet",
		Values = { "Tier 1 > Tier 2", "Tier 2 > Tier 3", "Tier 3 > Tier 4" },
		Multi = true,
		Default = { "" },
	})

	exchangeSection:AddToggle("AutoExchangePotions", {
		Title = "Auto Exchange Potions",
		Description = "",
		Default = false,
		Callback = function(state)
			State.scriptSettings.ExchangeTab.Potions.AutoPotions = state
		end,
	})

	potionsDropdown:OnChanged(function(Value)
		State.scriptSettings.ExchangeTab.Potions.SelectedTiers = Value
	end)
end
