getgenv().DH = getgenv().DH or {}
getgenv().DH.UI = getgenv().DH.UI or {}
getgenv().DH.UI.UpdateLogs = {}

local UIUpdateLogs = getgenv().DH.UI.UpdateLogs

function UIUpdateLogs.build(Tabs)
	local main = Tabs.UpdateLogs:AddSection("Patch Notes")

	main:AddParagraph({
		Title = "Patch: 27/03/2026",
		Content = "Added:\n \n - Dropdown for Exchange Potions \n \nFixed: \n - Auto Join Selected Players breaking if player wasnt in server \n \nChanges: \n - Removed Auto Leave Gamemode toggle, now you js need to save pos and select wave to leave \n - Removed Gacha tab (until i fix it) \n \n version: 1.2.1",
	})

	main:AddParagraph({
		Title = "Patch: 25/03/2026",
		Content = "Added:\n \n - Priority Enemies Dropdown in Farm/Gamemodes Tab \n - Pré-Support for Exchange Potions Tier 4 (Game not released this exchange yet) \n - Potions Tab with Auto Pause/UnPause Potions and Auto Use \n \nFixed: \n - Gamemode Auto Leave wasnt coming back to saved pos after complete/timeout \n \n version: 1.2.0",
	})
end
