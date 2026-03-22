getgenv().DH = getgenv().DH or {}
getgenv().DH.Exchange = {}

local Exchange = getgenv().DH.Exchange
local State = getgenv().DH.State

local Framework = State.Framework

function Exchange.UsePotions(mode: "1" | "2")
	if mode == "1" then
		for potion, value in ipairs(Framework.PlayerData.Inventory) do
			if potion:match("Potion1") then
				if value == 0 then
					return
				end

				local amount = value / 5
				Framework.Remote:Fire("Exchange", "Make", "Potion", "Tier 1", potion, amount)
			end
		end
	elseif mode == "2" then
		for potion, value in ipairs(Framework.PlayerData.Inventory) do
			print("Step 1")
			if potion:match("Potion2") then
				print(potion, value)
				if value == 0 then
					print("Value 0")
					return
				end

				local amount = value / 5
				print(typeof(value))
				Framework.Remote:Fire("Exchange", "Make", "Potion", "Tier 2", potion, amount)
			end
		end
	end
end
