getgenv().DH = getgenv().DH or {}
getgenv().DH.Exchange = {}

local Exchange = getgenv().DH.Exchange
local State = getgenv().DH.State

local Framework = State.Framework

function Exchange.UsePotions(type: "1" | "2")
	if type == "1" then
		for potion, value in ipairs(Framework.PlayerData.Inventory) do
			if potion:match("Potion1") then
				if value == 0 then
					return
				end

				local amount = math.floor((value or 0) / 5)
				Framework.Remote:Fire("Exchange", "Make", "Potion", "Tier 1", potion, amount)
			end
		end
	elseif type == "2" then
		for potion, value in ipairs(Framework.PlayerData.Inventory) do
			if potion:match("Potion2") then
				if value == 0 then
					return
				end

				local amount = math.floor((value or 0) / 5)
				Framework.Remote:Fire("Exchange", "Make", "Potion", "Tier 2", potion, amount)
			end
		end
	end
end
