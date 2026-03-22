getgenv().DH = getgenv().DH or {}
getgenv().DH.Exchange = {}

local Exchange = getgenv().DH.Exchange
local State = getgenv().DH.State

local Framework = State.Framework

function Exchange.UsePotions(mode: "1" | "2")
	print("[UsePotions] Chamado com mode:", mode)

	if mode == "1" then
		local hasPotion = false
		for potion, value in Framework.PlayerData.Inventory do
			print("[Check Tier 1] Potion:", potion, "| Value:", value)
			if potion:match("1") and value >= 5 then
				print("[Check Tier 1] Encontrou poção válida:", potion, value)
				hasPotion = true
				break
			end
		end

		print("[Tier 1] hasPotion:", hasPotion)
		if not hasPotion then
			print("[Tier 1] Nenhuma poção válida, saindo.")
			return
		end

		for potion, value in Framework.PlayerData.Inventory do
			if potion:match("1") and value >= 5 then
				local amount = math.floor(value / 5)
				print("[Tier 1] Firing:", potion, "| Value:", value, "| Amount:", amount)
				Framework.Remote:Fire("Exchange", "Make", "Potion", "Tier 1", potion, amount)
			end
		end
	elseif mode == "2" then
		local hasPotion = false
		for potion, value in Framework.PlayerData.Inventory do
			print("[Check Tier 2] Potion:", potion, "| Value:", value)
			if potion:match("2") and value >= 5 then
				print("[Check Tier 2] Encontrou poção válida:", potion, value)
				hasPotion = true
				break
			end
		end

		print("[Tier 2] hasPotion:", hasPotion)
		if not hasPotion then
			print("[Tier 2] Nenhuma poção válida, saindo.")
			return
		end

		for potion, value in Framework.PlayerData.Inventory do
			if potion:match("2") and value >= 5 then
				local amount = math.floor(value / 5)
				print("[Tier 2] Firing:", potion, "| Value:", value, "| Amount:", amount)
				Framework.Remote:Fire("Exchange", "Make", "Potion", "Tier 2", potion, amount)
			end
		end
	end

	print("[UsePotions] Finalizado.")
end
