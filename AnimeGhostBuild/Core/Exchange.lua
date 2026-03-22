getgenv().DH = getgenv().DH or {}
getgenv().DH.Exchange = {}

local Exchange = getgenv().DH.Exchange
local State = getgenv().DH.State

local Framework = State.Framework

function Exchange.UsePotions(mode: "1" | "2")
	print("[UsePotions] Chamado com mode:", mode)
	local tier = mode == "1" and "Tier 1" or "Tier 2"

	for potion, value in Framework.PlayerData.Inventory do
		if potion:match(mode) then
			local amount = math.floor(value / 5)
			if amount < 1 then
				print("[Skip]", potion, "| Amount insuficiente:", amount)
				continue
			end

			print("[Firing]", potion, "| Value:", value, "| Amount:", amount)
			Framework.Remote:Fire("ExchangeSystem", "Make", "Potion", tier, potion, amount)

			task.wait(1) -- espera 1 tick completo pra BridgeNet2 mandar o pacote antes do próximo
		end
	end

	print("[UsePotions] Finalizado.")
end
