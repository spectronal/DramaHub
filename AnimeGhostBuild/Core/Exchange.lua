getgenv().DH = getgenv().DH or {}
getgenv().DH.Exchange = {}

local Exchange = getgenv().DH.Exchange
local State = getgenv().DH.State

local Framework = State.Framework

function Exchange.UsePotions(mode: "1" | "2")
	if mode == "1" then
		local hasPotion = false
		for potion, value in Framework.PlayerData.Inventory do
			if potion:match("1") and value >= 5 then
				hasPotion = true
				break
			end
		end

		if not hasPotion then
			return
		end

		for potion, value in Framework.PlayerData.Inventory do
			if potion:match("1") and value >= 5 then
				local amount = value / 5
				Framework.Remote:Fire("Exchange", "Make", "Potion", "Tier 1", potion, amount)
			end
		end
	elseif mode == "2" then
		local hasPotion = false
		for potion, value in Framework.PlayerData.Inventory do
			if potion:match("2") and value >= 5 then
				hasPotion = true
				break
			end
		end

		if not hasPotion then
			return
		end

		for potion, value in Framework.PlayerData.Inventory do
			if potion:match("2") and value >= 5 then
				local amount = value / 5
				Framework.Remote:Fire("Exchange", "Make", "Potion", "Tier 2", potion, amount)
			end
		end
	end
end
