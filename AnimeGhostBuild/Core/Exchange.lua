getgenv().DH = getgenv().DH or {}
getgenv().DH.Exchange = {}

local Exchange = getgenv().DH.Exchange
local State = getgenv().DH.State

local Framework = State.Framework

function Exchange.UsePotions(mode: "1" | "2")
	print("Fora")
	if mode == "1" then
		print("1")
		for potion, value in Framework.PlayerData.Inventory do
			if potion:match("1") then
				if value == 0 then
					return
				end

				local amount = value / 5
				Framework.Remote:Fire("Exchange", "Make", "Potion", "Tier 1", potion, amount)
			end
		end
	elseif mode == "2" then
		print("2")
		for potion, value in Framework.PlayerData.Inventory do
			print(typeof(potion))
			if potion:match("2") then
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
