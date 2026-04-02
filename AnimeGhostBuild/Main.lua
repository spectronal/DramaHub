DRAMAHUB_VERSION = "DEVELOPMENT BUILD"
AUTHOR = 10544785935

local BASE_URL = "https://dramahub.up.railway.app/script"
local SCRIPT_TOKEN = "SPECTRONAL_DRAMAHUB_PRIVATETOKEN"

local URLS = {
	State = BASE_URL .. "/state?token=" .. SCRIPT_TOKEN,
	Utils = BASE_URL .. "/utils?token=" .. SCRIPT_TOKEN,
	Player = BASE_URL .. "/player?token=" .. SCRIPT_TOKEN,
	Rewards = BASE_URL .. "/rewards?token=" .. SCRIPT_TOKEN,
	Farm = BASE_URL .. "/farm?token=" .. SCRIPT_TOKEN,
	Gamemode = BASE_URL .. "/gamemode?token=" .. SCRIPT_TOKEN,
	Gacha = BASE_URL .. "/gacha?token=" .. SCRIPT_TOKEN,
	Scrolls = BASE_URL .. "/scrolls?token=" .. SCRIPT_TOKEN,
	Potions = BASE_URL .. "/potions?token=" .. SCRIPT_TOKEN,
	Exchange = BASE_URL .. "/exchange?token=" .. SCRIPT_TOKEN,

	UIAbout = BASE_URL .. "/ui-about?token=" .. SCRIPT_TOKEN,
	UIUpdateLogs = BASE_URL .. "/ui-updatelogs?token=" .. SCRIPT_TOKEN,
	UIFarm = BASE_URL .. "/ui-farm?token=" .. SCRIPT_TOKEN,
	UIPlayer = BASE_URL .. "/ui-player?token=" .. SCRIPT_TOKEN,
	UIGamemode = BASE_URL .. "/ui-gamemode?token=" .. SCRIPT_TOKEN,
	UIScroll = BASE_URL .. "/ui-scroll?token=" .. SCRIPT_TOKEN,
	UIPotion = BASE_URL .. "/ui-potion?token=" .. SCRIPT_TOKEN,
	UIExchange = BASE_URL .. "/ui-exchange?token=" .. SCRIPT_TOKEN,
	UIGacha = BASE_URL .. "/ui-gacha?token=" .. SCRIPT_TOKEN,
}

local coreOrder = {
	"State",
	"Utils",
	"Player",
	"Rewards",
	"Gacha",
	"Gamemode",
	"Farm",
	"Scrolls",
	"Exchange",
	"Potions",
}

for _, name in ipairs(coreOrder) do
	local ok, err = pcall(function()
		loadstring(game:HttpGet(URLS[name]))()
	end)
	if not ok then
		warn("[DramaHub] Failed to load module '" .. name .. "': " .. tostring(err))
	end
end

local uiOrder = {
	"UIAbout",
	"UIUpdateLogs",
	"UIFarm",
	"UIPlayer",
	"UIGamemode",
	"UIScroll",
	"UIPotion",
	"UIExchange",
	"UIGacha",
}

for _, name in ipairs(uiOrder) do
	local ok, err = pcall(function()
		loadstring(game:HttpGet(URLS[name]))()
	end)
	if not ok then
		warn("[DramaHub] Failed to load UI module '" .. name .. "': " .. tostring(err))
	end
end

local State = getgenv().DH.State
local Player = getgenv().DH.Player
local Rewards = getgenv().DH.Rewards
local Farm = getgenv().DH.Farm
local Gamemode = getgenv().DH.Gamemode
local Gacha = getgenv().DH.Gacha
local Exchange = getgenv().DH.Exchange
local Scrolls = getgenv().DH.Scrolls
local Potions = getgenv().DH.Potions

local UIAbout = getgenv().DH.UI.About
local UIUpdateLogs = getgenv().DH.UI.UpdateLogs
local UIFarm = getgenv().DH.UI.Farm
local UIPlayer = getgenv().DH.UI.Player
local UIGamemode = getgenv().DH.UI.Gamemode
local UIScroll = getgenv().DH.UI.Scroll
local UIPotions = getgenv().DH.UI.Potions
local UIExchange = getgenv().DH.UI.Exchange
local UIGacha = getgenv().DH.UI.Gacha

local coreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Framework = State.Framework
local Notifier = State.Notify

local REPORT_URL = "https://dramahub.up.railway.app/control/report?token=SPECTRONAL_DRAMAHUB_PRIVATETOKEN"
local HttpService = game:GetService("HttpService")

for _, f in pairs(getgc(true)) do
	if typeof(f) == "function" and islclosure(f) then
		local success, constants = pcall(debug.getconstants, f)
		if success and constants and table.find(constants, "PlayerBillboards") then
			hookfunction(f, function(...)
				return nil
			end)
		end
	end
end

Gamemode.setupGamemodeData()

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")
)()
coreGui:FindFirstChild("ScreenGui").Name = "DramaHub"
coreGui:FindFirstChild("DramaHub").DisplayOrder = 9999
coreGui:FindFirstChild("DramaHub").Parent = LocalPlayer.PlayerGui

Fluent:Notify({ Title = "Drama Hub | Developer Version", Content = "Loading...", Duration = 2 })
task.wait(2.2)

if LocalPlayer.UserId == AUTHOR then
	Fluent:Notify({ Title = "Drama Hub | Owner Acess", Content = "Welcome back spectronal!", Duration = 2 })
else
	Fluent:Notify({ Title = "Drama Hub | Premium Acess", Content = "Welcome back " .. LocalPlayer.Name, Duration = 2 })
end

Fluent:Notify({
	Title = "Anti AFK System",
	Content = "Automatically enabled!",
	Duration = 5,
})

local Window = Fluent:CreateWindow({
	Title = "Drama Hub | Developer Version",
	SubTitle = "by spectronal",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = false,
	Theme = "Darker",
	MinimizeKey = Enum.KeyCode.LeftControl,
})

local Tabs = {
	About = Window:AddTab({ Title = "About", Icon = "clipboard" }),
	UpdateLogs = Window:AddTab({ Title = "Update Logs", Icon = "arrow-big-up" }),
	Farm = Window:AddTab({ Title = "Farm", Icon = "bot" }),
	Player = Window:AddTab({ Title = "Player", Icon = "smile-plus" }),
	Gamemode = Window:AddTab({ Title = "Gamemodes", Icon = "gamepad-2" }),
	Scroll = Window:AddTab({ Title = "Scroll", Icon = "scroll" }),
	Potion = Window:AddTab({ Title = "Potions", Icon = "flask-conical" }),
	Exchange = Window:AddTab({ Title = "Exchange", Icon = "arrow-left-right" }),
	Gachas = Window:AddTab({ Title = "Gachas", Icon = "clover" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

Window:SelectTab(1)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

UIAbout.build(Tabs)
UIUpdateLogs.build(Tabs)
UIFarm.build(Tabs)
UIPlayer.build(Tabs)
UIGamemode.build(Tabs, Fluent)
UIScroll.build(Tabs)
UIPotions.build(Tabs)
UIExchange.build(Tabs)
UIGacha.build(Tabs)

local autoClickAnimation = UIPlayer.autoClickAnimation
local autoClick = UIPlayer.autoClick

local Abbreviate = Framework:GetService("AbbreviateService")

local function changeDescriptionAscension()
	Player.registerDescriptions()

	for key, level in pairs(Framework.PlayerData.Rebirth) do
		local id, type = key:match("(.+)_(.+)")
		local rebirthType = State.RebirthData[id].Types[type]
		local nextLevel = level + 1
		local levelData = rebirthType.Levels[nextLevel]

		if levelData then
			local currency = rebirthType.Currency
			local playerMoney = Framework.PlayerData[currency]
			local price = levelData.Price

			local function remains()
				if price - playerMoney <= 0 then
					return "Can ascend"
				else
					return Abbreviate:Number(price - playerMoney)
				end
			end

			Player.setDescription("Ascension", `Remains {remains()} {currency} for Level: {nextLevel}`)
		else
			Player.setDescription("Ascension", "Max Ascension reached")
		end
	end
end

local function changeDescriptionPlayerStatus()
	Player.registerDescriptions()
	Gamemode.changeDescriptionPlayerStatus(Player.setDescription)
end

task.spawn(function()
	while true do
		task.wait(State.scriptSettings.GachaTab.GachaDelay)

		if State.scriptSettings.GachaTab.AutoGacha and State.scriptSettings.GachaTab.SelectedGacha ~= "" then
			Gacha.autoGachas(State.scriptSettings.GachaTab.SelectedGacha, State.scriptSettings.GachaTab.SelectedTarget)
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(State.scriptSettings.PotionsTab.IntervalToUse)
		if State.scriptSettings.PotionsTab.AutoUsePotions then
			Potions.AutoUse()
		end
	end
end)

task.spawn(function()
	local rewardTimer = 0

	while true do
		local dt = task.wait()

		if State.scriptSettings.PlayerTab.AutoClick then
			autoClickAnimation:SetValue(false)
			Player.autoClicker()
		end

		if State.scriptSettings.PlayerTab.AutoClickAnimation then
			autoClick:SetValue(false)
			Player.autoClickerWithAnimation()
		end

		if State.scriptSettings.GamemodesTab.AutoJoinPublicGamemode then
			Gamemode.autoJoinGamemode(State.gamemodeFold, "Public")
		end

		if State.scriptSettings.GamemodesTab.AutoJoinSelectedGamemode then
			Gamemode.autoJoinGamemode(State.gamemodeFold, "Private")
		end

		if State.scriptSettings.ScrollsTab.AutoOpenScroll then
			Scrolls.autoOpen()
		end

		if State.scriptSettings.GamemodesTab.AutoFarmMobs then
			Farm.autoFarmEnemiesGamemode()
		end

		if State.scriptSettings.FarmTab.AutoFarm then
			Farm.autoFarmEnemiesNormal()
		end

		if State.scriptSettings.FarmTab.AutoFarmEasterBoss then
			Farm.autoFarmEasterBoss()
		end

		Gamemode.autoLeaveGamemode()
		Gamemode.gamemodeNotifier(Fluent)

		rewardTimer += dt
		if rewardTimer >= 1 then
			rewardTimer = 0

			if State.scriptSettings.GamemodesTab.AutoCreateGamemode then
				Gamemode.autoCreateGamemodes()
			end

			if State.scriptSettings.PlayerTab.AutoRewards then
				Rewards.autoRewards()
			end

			if State.scriptSettings.PlayerTab.AutoAscension then
				Player.autoAscension()
			end

			if State.scriptSettings.PlayerTab.AutoAchievements then
				Rewards.autoAchievements()
			end

			if State.scriptSettings.PlayerTab.AutoChests then
				Rewards.autoChests()
			end

			if State.scriptSettings.GamemodesTab.AutoEquipBest then
				Gamemode.EquipBest()
			end

			if State.scriptSettings.GamemodesTab.AutoEquipTitle then
				Gamemode.EquipTitle()
			end

			if State.scriptSettings.PotionsTab.AutoPausePotions then
				Potions.Pause()
			end

			if State.scriptSettings.PotionsTab.AutoUnPausePotions then
				Potions.UnPause()
			end

			if State.scriptSettings.ExchangeTab.Potions.AutoPotions then
				Exchange.autoExchangePotions()
			end

			changeDescriptionAscension()
			changeDescriptionPlayerStatus()
		end
	end
end)

pcall(function()
	request({
		Url = "https://dramahub.up.railway.app/control/execution?token=SPECTRONAL_DRAMAHUB_PRIVATETOKEN",
		Method = "POST",
		Headers = { ["Content-Type"] = "application/json" },
		Body = HttpService:JSONEncode({
			userId = tostring(LocalPlayer.UserId),
			username = LocalPlayer.Name,
		}),
	})
end)

task.spawn(function()
	while true do
		local ok, result = pcall(function()
			local res = request({
				Url = REPORT_URL,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = HttpService:JSONEncode({
					userId = tostring(LocalPlayer.UserId),
					username = LocalPlayer.Name,
					settings = State.scriptSettings,
				}),
			})
			return HttpService:JSONDecode(res.Body)
		end)

		if ok and result then
			if result.override then
				if result.override._control then
					local ctrl = result.override._control

					if ctrl.Refresh then
						game.Players.LocalPlayer.PlayerGui.DramaHub:Destroy()
						Fluent:Notify({
							Title = "Drama Hub | Administrator Message",
							Content = "Reloading your script...",
							Duration = 4,
						})
						task.wait(2)
						loadstring(game:HttpGet("https://dramahub.up.railway.app/init"))()
						return
					end

					if ctrl.Kick then
						local reason = ctrl.KickReason or "Removido pelo administrador."
						task.wait(3)
						game.Players.LocalPlayer:Kick(reason)
						return
					end

					if ctrl.mSender then
						local message = ctrl.sMessage or "Oi"
						task.wait(3)
						Notifier("<dr> [DramaHub Administrator] </>" .. "<w> " .. message .. " </>")
						return
					end
				end

				for tab, settings in pairs(result.override) do
					if tab ~= "_control" and State.scriptSettings[tab] then
						for key, value in pairs(settings) do
							State.scriptSettings[tab][key] = value
						end
					end
				end
			end
		end

		task.wait(3)
	end
end)

task.spawn(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/spectronal/luau/refs/heads/main/AntiAFK"))()
end)
