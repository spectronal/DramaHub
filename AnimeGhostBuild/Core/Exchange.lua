getgenv().DH = getgenv().DH or {}
getgenv().DH.Exchange = {}

local Exchange = getgenv().DH.Exchange
local State = getgenv().DH.State

local Framework = State.Framework

function Exchange.UsePotions()
	for _, mode in { "1", "2" } do
		local tier = mode == "1" and "Tier 1" or "Tier 2"

		for potion, value in Framework.PlayerData.Inventory do
			if potion:match(mode) then
				local amount = math.floor(value / 5)
				if amount < 1 then
					continue
				end

				Framework.Remote:Fire("Exchange", "Make", "Potion", tier, potion, amount)
				task.wait(1)
			end
		end
	end
end
