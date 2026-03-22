getgenv().DH = getgenv().DH or {}
getgenv().DH.UI = getgenv().DH.UI or {}
getgenv().DH.UI.Exchange = {}

local UIExchange = getgenv().DH.UI.Exchange

function UIExchange.build(Tabs)
	local State = getgenv().DH.State

	local exchangeSection = Tabs.Exchange:AddSection("Potions")

	exchangeSection:AddToggle("AutoExchangePotions", {
		Title = "Auto Exchange Potions",
		Description = "Exchange Tier 1 and Tier 2 potions",
		Default = false,
		Callback = function(state)
			State.scriptSettings.ExchangeTab.Potions.AutoPotions = state
		end,
	})
end
