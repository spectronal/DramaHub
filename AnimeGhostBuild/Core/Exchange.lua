getgenv().DH = getgenv().DH or {}
getgenv().DH.Exchange = {}

local Exchange = getgenv().DH.Exchange
local State = getgenv().DH.State

local Framework = State.Framework

local function usePotions(mode: "1" | "2" | "3")
	local tier = mode == "1" and "Tier 1" or "Tier 2" or "Tier 3"

	for potion, value in Framework.PlayerData.Inventory do
		if potion:match(mode) then
			local amount = math.floor(value / 5)
			if amount < 1 then
				continue
			end

			Framework.Remote:Fire("ExchangeSystem", "Make", "Potion", tier, potion, amount)

			task.wait(1)
		end
	end
end

function Exchange.autoExchangePotions()
	for potionMode, i in State.scriptSettings.ExchangeTab.Potions.SelectedTiers or {} do
		print(potionMode, i)
		if potionMode:match("Tier 1 > Tier 2") then
			usePotions("1")
		elseif potionMode:match("Tier 2 > Tier 3") then
			usePotions("2")
		elseif potionMode:match("Tier 3 > Tier 4") then
			usePotions("3")
		end
	end
end
