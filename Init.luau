-- DramaHub: Anime Ghost
-- Version: 1.0.85
-- Update Logs: for Gamemode: Added Auto Farm Mobs, Save Position/Return World and Status Mode (QOL), for general: Added custom DramaHub Roles, Result UI is not appearing anymore and new Hub notifiers (QOL)
-- Errors: 1.5 (1: Warriors is not focusing in the main enemy in gamemodes, idk how i'll fix it | 0.5: I think the general performance is bad, i'll fix it tomorrow)
-- Expected for 1.0.9: New Farm Tab (with autofarm for all the maps + autofarm mobs with scroll hatch), New Scroll Tab (Scroll Farm for all the maps btw), New Section of Equip best in Gamemode Tab, and for end, new Exchange Tab (for potions and tokens)

DRAMAHUB_VERSION = "DEVELOPMENT BUILD"
AUTHOR = 10544785935

local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Framework = require(replicatedStorage.Framework.Library)
local Abbreviate = Framework:GetService("AbbreviateService")
local MultiplierService = Framework:GetService("MultiplierService")
local DebounceService = Framework:GetService("DebounceService")
local AnimationService = Framework:GetService("AnimationService")

local scriptSettings = {
	PlayerTab = {
		AutoClick = false,
		AutoClickAnimation = false,
		AutoAscension = false,
		AutoRewards = false,
		AutoAchievments = false,
		AutoChests = false,
	},
	GachaTab = {
		SelectedGacha = "",
		SelectedTarget = { "" },
		GachaDelay = 0.1,
		AutoGacha = false,
	},
	GamemodesTab = {
		SelectedGamemode = { "" },
		SelectedRaid = "",
		SelectedDungeon = "",
		SelectedInfinityCastle = "",

		SelectedRaidDifficulty = "",
		SelectedDungeonDifficulty = "",
		SelectedInfinityCastleDifficulty = "",

		SelectedPlayersToJoin = { "" },

		RaidToLeave = 0,
		DungeonToLeave = 0,
		InfinityCastleToLeave = 0,

		AutoJoinPublicGamemode = false,
		AutoJoinSelectedGamemode = false,
		AutoCreateGamemode = false,
		AutoLeaveGamemode = false,
		AutoFarmMobs = false,
		WorldToTeleport = 0,
		SavedPosition = nil,
	},
	Roles = {
		["DRAMAHUB DEVELOPER"] = Color3.new(1, 0, 0),
		["DRAMAHUB PREMIUM"] = Color3.new(1, 0.682353, 0),
		["DRAMAHUB USER"] = Color3.new(0, 0.882353, 1),
	},
}

-- GetData
local TimeRewardData = Framework:GetData("TimeRewardData")
local WeeklyRewardData = Framework:GetData("WeeklyRewardData")
local WeeklyRewardService = Framework:GetService("WeeklyRewardService")
local RebirthData = Framework:GetData("RebirthData")
local AchievementData = Framework:GetData("AchievementData")
local ChestData = Framework:GetData("ChestData")
local GachaData = Framework:GetData("GachaData")
local GamemodeData = Framework:GetData("GamemodeData")
local MapData = Framework:GetData("MapData")

-- Gacha
local Gachas = {}
local Targets = {}

for id in pairs(GachaData) do
	table.insert(Gachas, id)
end

-- Gamemodes
local PlayersInGamemodes = {}
local Gamemodes = {}

local PriorityMap = {
	["Raid"] = 1,
	["Dungeon"] = 2,
	["Infinity Castle"] = 3,
}

local cooldowns = {
	Raid = 0,
	Dungeon = 0,
	["Infinity Castle"] = 0,
}

local MapsNum = {}
local RaidData = {}
local DungeonData = {}
local InfinityData = {}

local gamemodeFold = workspace:WaitForChild("_MAP"):WaitForChild("Gamemode")
local gamemodeServer = replicatedStorage:WaitForChild("Server").Gamemode

local lastCreate = 0

-- AutoClicker with animation
local lastClickTime = tick()
local comboIndex = 0

-- Auto Farm Mobs
local enemiesFolder = workspace["_ENEMIES"].Server

-- Roles
local RoleLabel = workspace._CHARACTERS[LocalPlayer.Name].GUI.Role

Framework.Remote:Connect(function(data)
	if data[1] == "Notify" then
		local msg = tostring(data[2])
		local m, s = msg:match("(%d+)m%s*(%d+)s")
		if not (m and s) then
			return
		end

		local total = tonumber(m) * 60 + tonumber(s)

		-- detecta qual modo
		if msg:find("Raid") then
			cooldowns.Raid = tick() + total
		elseif msg:find("Dungeon") then
			cooldowns.Dungeon = tick() + total
		elseif msg:find("Infinity Castle") then
			cooldowns["Infinity Castle"] = tick() + total
		end
	end
end)

local function Color3ToHex(color)
	local r = math.clamp(math.floor(color.R * 255), 0, 255)
	local g = math.clamp(math.floor(color.G * 255), 0, 255)
	local b = math.clamp(math.floor(color.B * 255), 0, 255)
	return string.format("%02X%02X%02X", r, g, b)
end

for _, f in pairs(getgc(true)) do
	if typeof(f) == "function" and islclosure(f) then
		local success, constants = pcall(debug.getconstants, f)

		if success and constants and table.find(constants, "PlayerBillboards") then
			local old = f

			hookfunction(f, function(...)
				return nil
			end)
		end
	end
end

LocalPlayer.PlayerGui.Results.Content.Visible = false

local function setupGamemodeData()
	for role, color in pairs(scriptSettings.Roles) do
		print(role)

		if DRAMAHUB_VERSION == "DEVELOPMENT BUILD" then
			RoleLabel.RichText = true

			if LocalPlayer.UserId == AUTHOR then
				if role == "DRAMAHUB DEVELOPER" then
					RoleLabel.Text = string.format("<font color='#%s'>[%s]</font>", Color3ToHex(color), role)
				end
			else
				RoleLabel.Text = string.format("<font color='#%s'>[%s]</font>", Color3ToHex(color), role)
			end
		end
	end

	for id in pairs(GamemodeData) do
		table.insert(Gamemodes, id)
	end

	for players, names in pairs(Players:GetPlayers()) do
		table.insert(PlayersInGamemodes, names.Name)
	end

	for raids, value in pairs(GamemodeData["Raid"]) do
		table.insert(RaidData, raids)
	end

	for dungeons, value in pairs(GamemodeData["Dungeon"]) do
		table.insert(DungeonData, dungeons)
	end

	for infinity, value in pairs(GamemodeData["Infinity Castle"]) do
		table.insert(InfinityData, infinity)
	end

	for maps, value in ipairs(MapData) do
		table.insert(MapsNum, maps)
	end
end

setupGamemodeData()

local function autoClicker()
	Framework.Remote:Fire("ClickSystem", "Execute", Framework.Target)
end

local function autoClickerWithAnimation()
	if Framework.LocalPlayer:GetAttribute("UsingSkill") then
		return
	end

	if DebounceService.Check(Framework.LocalPlayer, "Click", 0.05) then
		return
	end

	Framework.Remote:Fire("ClickSystem", "Execute", Framework.Target)

	local atkSpeed = MultiplierService.AtkSPD(Framework.LocalPlayer)
	local animationSpeed = 0.6 / atkSpeed

	if not DebounceService.Check(Framework.LocalPlayer, "ClickAnimation", atkSpeed * 1.1) then
		-- combo system
		comboIndex += 1

		if tick() - lastClickTime > 2 then
			comboIndex = 1
		end

		if comboIndex > 3 then
			comboIndex = 1
		end

		lastClickTime = tick()

		local animationType = "Punch"

		if not Framework.PlayerData.Settings.HideWeapon then
			local weaponTypes = {
				"Weapon",
				"DualWeapon",
				"TripleWeapon",
			}

			local equipped = #Framework.PlayerData.WeaponsEquipped

			if equipped > 0 then
				animationType = weaponTypes[equipped]
			end
		end

		if not Framework.LocalPlayer:GetAttribute("OnMount") then
			AnimationService.Load(
				Framework.LocalPlayer.Character.Humanoid.Animator,
				("%s %s"):format(animationType, comboIndex),
				animationSpeed,
				"Action2"
			)
		end
	end
end

local function GetCurrentTier(typeName)
	local completed = 0

	for id, _ in Framework.PlayerData.Achievements do
		if id:match(typeName) then
			completed += 1
		end
	end

	local nextTier = completed + 1

	if AchievementData[typeName .. nextTier] then
		return typeName .. nextTier, nextTier
	else
		return typeName .. completed, completed
	end
end

local function GetAchievementTypes()
	local types = {}

	for key, _ in AchievementData do
		local name = string.gsub(key, "%d+", "")

		if not table.find(types, name) then
			table.insert(types, name)
		end
	end

	return types
end

local function GetClaimableAchievements()
	local claimable = {}

	for _, typeName in GetAchievementTypes() do
		local id = GetCurrentTier(typeName)

		local data = AchievementData[id]

		local stat = Framework.PlayerData.TotalStats[data.DataUsed] or 0

		local goal = data.Goal

		stat = math.min(stat, goal)

		local claimed = Framework.PlayerData.Achievements[id] or false

		if goal <= stat and not claimed then
			claimable[id] = true
		end
	end

	return claimable
end

local function autoGachas(Gacha: string, Target)
	Framework.Remote:Fire("GachaSystem", "Spin", Gacha, "Normal", {}, Target)
end

local function autoAscension()
	for key, level in pairs(Framework.PlayerData.Rebirth) do
		local id, type = key:match("(.+)_(.+)")
		local rebirthType = RebirthData[id].Types[type]

		local nextLevel = level + 1
		local levelData = rebirthType.Levels[nextLevel]

		if levelData then
			local currency = rebirthType.Currency
			local playerMoney = Framework.PlayerData[currency]
			local price = levelData.Price

			if playerMoney >= price then
				Framework.Remote:Fire("RebirthSystem", "Release", id, type)
			end
		end
	end
end

local function removeCutscene()
	local oldRequire = require

	require = function(module)
		if module == Framework.Modules.Client.Controllers.CutsceneController.Ascension then
			return function() end
		end

		return oldRequire(module)
	end
end

local function removeGachaAnimation()
	local mod = require(Framework.Modules.Services.GachaService)

	mod.SetupAnimation = function()
		return
	end
	mod.QuitAnimation = function()
		return
	end
	mod.StartAnimation = function()
		return
	end
end

local function autoRewards()
	local PlayerData = Framework.PlayerData
	--  print(PlayerData and PlayerData.TimeRewards)

	for typeName, config in pairs(TimeRewardData) do
		local data = PlayerData.TimeRewards[typeName]

		if data then
			local time = data.Time

			for index, reward in pairs(config.Rewards) do
				if not data.Claimed[index] and reward.Time < time then
					Framework.Remote:Fire("TimeRewardSystem", "Claim", typeName, index)
					--print("Claiming reward", typeName, index)
				end
			end

			if time >= config.ResetTime then
				Framework.Remote:Fire("TimeRewardSystem", "Reset", typeName)
			end
		end
	end

	local currentDay = WeeklyRewardService.CurrentDay()

	for typeName, _ in pairs(WeeklyRewardData) do
		local playerData = Framework.PlayerData.WeeklyRewards[typeName]
		if playerData then
			if not playerData.Claimed[tostring(currentDay)] and WeeklyRewardService.HOUR_TIME <= playerData.Time then
				Framework.Remote:Fire("WeeklyRewardSystem", "Claim", typeName, currentDay)
			end
		end
	end
end

local function autoAchievements()
	for _, typeName in GetAchievementTypes() do
		local id = GetCurrentTier(typeName)

		if GetClaimableAchievements()[id] then
			Framework.Remote:Fire("AchievementSystem", "Claim", id)
		end
	end
end

local function autoChests()
	for chestId, chestConfig in pairs(ChestData) do
		if chestConfig.CanClaim(Framework.LocalPlayer) then
			Framework.Remote:Fire("ChestSystem", "Claim", chestId)
		end
	end
end

local function savePlayerPosition()
	local RootPart = workspace["_CHARACTERS"][LocalPlayer.Name].HumanoidRootPart
	scriptSettings.GamemodesTab.SavedPosition = RootPart.Position
end

local function teleportPlayerToPosition()
	local RootPart = workspace["_CHARACTERS"][LocalPlayer.Name].HumanoidRootPart
	Framework.Remote:Fire("TeleportSystem", "To", scriptSettings.GamemodesTab.WorldToTeleport)
	task.wait(1)
	RootPart.CFrame = CFrame.new(scriptSettings.GamemodesTab.SavedPosition)
end

local function inMode()
	local modeName = LocalPlayer:GetAttribute("InMode")
	if not modeName then
		return false
	end

	local mode = gamemodeServer:FindFirstChild(modeName)
	if not mode then
		return false
	end

	local playersFolder = mode:FindFirstChild("Players")
	if not playersFolder then
		return false
	end

	return playersFolder:GetAttribute(tostring(LocalPlayer.UserId)) ~= nil
end

local function isOnCooldown(mode)
	local remaining = (cooldowns[mode] or 0) - tick()

	if remaining > 0 then
		print(mode, "ainda em cooldown:", remaining)
	end

	return remaining > 0.5
end

local function getCooldownRemaining(mode)
	if not cooldowns[mode] then
		return 0
	end
	return math.max(0, cooldowns[mode] - tick())
end

local function formatTime(t)
	if inMode() then
		return "Running"
	end

	if t <= 0 then
		return "Ready"
	end
	local m = math.floor(t / 60)
	local s = math.floor(t % 60)
	return string.format("%d:%02d", m, s)
end

local function getCooldownsText()
	local parts = {}

	for mode, _ in pairs(cooldowns) do
		local remaining = getCooldownRemaining(mode)
		table.insert(parts, `{mode} : {formatTime(remaining)}`)
	end

	return table.concat(parts, " | ")
end

local function getPlayerMode(typeMode: "ModeId" | "Mode" | "StatusMode")
	for _, mode in pairs(gamemodeServer:GetChildren()) do
		if mode:IsA("Folder") then
			local playersFolder = mode:FindFirstChild("Players")

			if playersFolder and playersFolder:GetAttribute(tostring(LocalPlayer.UserId)) then
				if typeMode == "ModeId" then
					return mode:GetAttribute("ModeId")
				elseif typeMode == "Mode" then
					return mode.Name
				elseif typeMode == "StatusMode" then
					return mode:GetAttribute("Status")
				end
			end
		end
	end

	return nil
end

local function autoJoinGamemode(gamemode, select: "Private" | "Public")
	if inMode() then
		return
	end

	if select == "Private" then
		for playerName, key in pairs(scriptSettings.GamemodesTab.SelectedPlayersToJoin) do
			local player = Players[playerName]
			if player:GetAttribute("Mode") then
				local modeText = player:GetAttribute("Mode")

				if scriptSettings.GamemodesTab.SelectedGamemode[modeText] then
					Framework.Remote:Fire("GamemodeSystem", "Join", modeText, player.UserId)
				end
			end
		end
	elseif select == "Public" then
		for key, playerName in pairs(Players:GetPlayers()) do
			local player = Players[playerName.Name]
			if player:GetAttribute("Mode") then
				local modeText = player:GetAttribute("Mode")

				if scriptSettings.GamemodesTab.SelectedGamemode[modeText] then
					Framework.Remote:Fire("GamemodeSystem", "Join", modeText, player.UserId)
				end
			end
		end
	end
end

local function autoCreateGamemodes()
	if inMode() then
		return
	end

	if tick() - lastCreate < 2 then
		return
	end
	lastCreate = tick()

	local chosen
	local bestPriority = math.huge

	for gamemode, enabled in pairs(scriptSettings.GamemodesTab.SelectedGamemode) do
		if enabled then
			local priority = PriorityMap[gamemode]

			if priority and priority < bestPriority and not isOnCooldown(gamemode) then
				bestPriority = priority
				chosen = gamemode
			end
		end
	end

	if not chosen then
		return
	end

	local key = string.gsub("Selected" .. chosen, " ", "")
	local difficulty = string.gsub("Selected" .. chosen .. "Difficulty", " ", "")

	Framework.Remote:Fire(
		"GamemodeSystem",
		"Create",
		chosen,
		scriptSettings.GamemodesTab[key],
		scriptSettings.GamemodesTab[difficulty]
	)

	task.wait(1)

	Framework.Remote:Fire("GamemodeSystem", "Start", getPlayerMode("ModeId"), LocalPlayer.UserId)
end

local function autoLeaveGamemode()
	if not inMode() then
		return
	end

	local modeName = getPlayerMode("Mode")
	if not modeName then
		return
	end

	local mode = gamemodeServer:FindFirstChild(modeName)
	if not mode then
		return
	end

	local Wave = tonumber(mode:GetAttribute("Stage"))
	local CurrentMode = string.gsub(mode:GetAttribute("ModeId"), " ", "")
	local MaxWave = tonumber(scriptSettings.GamemodesTab[CurrentMode .. "ToLeave"])

	if MaxWave ~= 0 and Wave >= MaxWave or not LocalPlayer:GetAttribute("InMode") then
		if scriptSettings.GamemodesTab.SavedPosition ~= nil then
			teleportPlayerToPosition()
		else
			Framework.Remote:Fire("TeleportSystem", "To", "Lobby")
		end
	end
end

local PlayerRootPart = workspace["_CHARACTERS"][LocalPlayer.Name].HumanoidRootPart

local currentMob = nil
local lastHP = nil
local stuckTime = 0

local lastTeleport = 0
local teleportCooldown = 0.5

local function isFarFromMob(mob)
	if not mob then
		return false
	end
	return (PlayerRootPart.Position - mob.Position).Magnitude > 8
end

local function teleportToMob(mob)
	if not mob then
		return
	end

	if tick() - lastTeleport >= teleportCooldown then
		if isFarFromMob(mob) then
			--local offset = mob.CFrame.RightVector * -6
			local height = Vector3.new(0, 6, 0)

			PlayerRootPart.CFrame = CFrame.new(mob.Position + height)
			lastTeleport = tick()
		end
	end
end

local function getNextMob()
	local mobsList = {}

	for _, mob in pairs(enemiesFolder:WaitForChild("Gamemode"):GetDescendants()) do
		if
			mob:IsA("Part")
			and mob.Parent
			and mob.Parent.Name == getPlayerMode("Mode")
			and mob:GetAttribute("Order")
		then
			table.insert(mobsList, mob)
		end
	end

	for _, warriors in pairs(workspace["_WARRIORS"]:GetDescendants()) do
		if warriors:IsA("Model") and warriors.Parent:IsA("Folder") then
			local warriorRootPart = warriors.HumanoidRootPart

			warriorRootPart.Position = Vector3.new(workspace["_CHARACTERS"][LocalPlayer.Name].HumanoidRootPart.Position)
		end
	end

	table.sort(mobsList, function(a, b)
		return a:GetAttribute("Order") < b:GetAttribute("Order")
	end)

	return mobsList[1]
end

function autoFarmEnemies()
	if not currentMob or not currentMob.Parent then
		currentMob = getNextMob()
		lastHP = nil
		stuckTime = 0

		if currentMob then
			teleportToMob(currentMob)
		else
			return
		end
	end

	Framework.Remote:Fire("ClickSystem", "Execute", Framework.Target)

	teleportToMob(currentMob)

	local currentHP = currentMob:GetAttribute("HP")

	if lastHP then
		if currentHP == lastHP then
			stuckTime += 1
		else
			stuckTime = 0
		end

		if stuckTime >= 5 then
			teleportToMob(currentMob)
			stuckTime = 0
		end
	end

	lastHP = currentHP
end

local Descriptions = {}

local function registerDescriptions()
	for _, obj in ipairs(LocalPlayer.PlayerGui:WaitForChild("DramaHub"):GetDescendants()) do
		if obj:IsA("TextLabel") then
			if obj.Text:find("Calculing...") then
				obj.Name = "AscensionDescription"
				Descriptions["Ascension"] = obj
			elseif obj.Text:find("StatusMode") then
				obj.Name = "PlayerStatusDescription"
				Descriptions["PlayerStatus"] = obj
			end
		end
	end
end

local function setDescription(name, text)
	local label = Descriptions[name]
	if label then
		label.Text = text
	end
end

local function changeDescription(description: "Ascension" | "PlayerStatus")
	registerDescriptions()

	if description == "Ascension" then
		for key, level in pairs(Framework.PlayerData.Rebirth) do
			local id, type = key:match("(.+)_(.+)")
			local rebirthType = RebirthData[id].Types[type]

			local nextLevel = level + 1
			local levelData = rebirthType.Levels[nextLevel]

			if levelData then
				local currency = rebirthType.Currency
				local playerMoney = Framework.PlayerData[currency]
				local price = levelData.Price

				setDescription(
					"Ascension",
					`Remains {Abbreviate:Number(price - playerMoney)} {currency} for Level: {nextLevel}`
				)
			else
				setDescription("Ascension", "Max Ascension reached")
			end
		end
	elseif description == "PlayerStatus" then
		setDescription(
			"PlayerStatus",
			`Priority: Raid > Dungeon > Infinity Castle \n \nCooldowns: {getCooldownsText()} \n \nSaved Position: World: {tostring(
				scriptSettings.GamemodesTab.WorldToTeleport
			)} / {tostring(scriptSettings.GamemodesTab.SavedPosition)}`
		)
	end
end

local function refreshPlayersList(selectPlayersToJoin)
	table.clear(PlayersInGamemodes)

	for players, names in pairs(Players:GetPlayers()) do
		table.insert(PlayersInGamemodes, names.Name)
	end

	selectPlayersToJoin:SetValue(PlayersInGamemodes)
end

-- UI

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")
)()

coreGui:FindFirstChild("ScreenGui").Name = "DramaHub"
coreGui:FindFirstChild("DramaHub").DisplayOrder = 9999
coreGui:FindFirstChild("DramaHub").Parent = LocalPlayer.PlayerGui

local lastInMode = false
local lastMode = nil

local function gamemodeNotifier()
	local isIn = inMode()
	local mode = getPlayerMode("ModeId")

	local ownerName = "Unknown"
	if lastInMode and not isIn then
		Fluent:Notify({
			Title = "Gamemode System",
			Content = "You left the gamemode",
			Duration = 2,
		})
	end

	if not lastInMode and isIn then
		local ownerId = tonumber(string.match(LocalPlayer:GetAttribute("InMode") or "", "%d+"))

		if ownerId then
			local success, result = pcall(function()
				return Players:GetNameFromUserIdAsync(ownerId)
			end)

			if success then
				ownerName = result
			end
		end

		if ownerId == LocalPlayer.UserId then
			Fluent:Notify({
				Title = "Gamemode System",
				Content = "You created a " .. mode .. " gamemode",
				Duration = 2,
			})
		else
			Fluent:Notify({
				Title = "Gamemode System",
				Content = "Joined " .. ownerName .. "'s " .. mode,
				Duration = 2,
			})
		end
	end

	lastInMode = isIn
	lastMode = mode
end

Fluent:Notify({
	Title = "Drama Hub | Development Build",
	Content = "Loading...",
	Duration = 2,
})

task.wait(2.2)

if LocalPlayer.UserId == AUTHOR then
	Fluent:Notify({
		Title = "Drama Hub | Owner Acess",
		Content = "Welcome back spectronal!",
		Duration = 2,
	})
else
	Fluent:Notify({
		Title = "Drama Hub | Premium Acess",
		Content = "Welcome back " .. LocalPlayer.Name,
		Duration = 2,
	})
end

local Window = Fluent:CreateWindow({
	Title = "Drama Hub | Development Build",
	SubTitle = "by spectronal",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = false,
	Theme = "Darker",
	MinimizeKey = Enum.KeyCode.LeftControl,
})

local Tabs = {
	About = Window:AddTab({ Title = "About", Icon = "clipboard" }),
	Farm = Window:AddTab({ Title = "Farm", Icon = "bot" }),
	Player = Window:AddTab({ Title = "Player", Icon = "smile-plus" }),
	Gamemode = Window:AddTab({ Title = "Gamemodes", Icon = "gamepad-2" }),
	Scroll = Window:AddTab({ Title = "Scroll", Icon = "scroll" }),
	Gachas = Window:AddTab({ Title = "Gachas", Icon = "clover" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

Window:SelectTab(1)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- ABOUT
local mainAbout = Tabs.About:AddSection("Drama Hub")

mainAbout:AddParagraph({
	Title = "Version Development Build",
	Content = "\nThis is a development build of Drama Hub, an all-in-one script for Anime Ghost. \nThis build is not intended for public use and may contain bugs or unfinished features.\n\nCreated by spectronal",
})

-- PLAYER
local mainPlayer = Tabs.Player:AddSection("Main")
mainPlayer:AddParagraph({
	Title = "Player Features",
	Content = "\nHere you can find various features related to the player, such as auto-clicker and auto-rewards.",
})

local autoClickAnimation = mainPlayer:AddToggle("AutoClickAnimation", {
	Title = "Auto Click with Animation",
	Default = false,
	Callback = function(state)
		scriptSettings.PlayerTab.AutoClickAnimation = state
	end,
})

local autoClick = mainPlayer:AddToggle("AutoClick", {
	Title = "Auto Click without Animation",
	Default = false,
	Callback = function(state)
		scriptSettings.PlayerTab.AutoClick = state
	end,
})

local autoAscend = mainPlayer:AddToggle("AutoAscencion", {
	Title = "Auto Ascension",
	Description = "Calculing...",
	Default = false,
	Callback = function(state)
		scriptSettings.PlayerTab.AutoAscension = state
	end,
})

local removeCuts = mainPlayer:AddButton({
	Title = "Remove Ascension Cutscene",
	Callback = function()
		removeCutscene()
	end,
})

local mainPlayer2 = Tabs.Player:AddSection("Auto Collect")

local autoReward = mainPlayer2:AddToggle("AutoRewards", {
	Title = "Auto Collect Rewards",
	Default = false,
	Callback = function(state)
		scriptSettings.PlayerTab.AutoRewards = state
	end,
})

local autoAchievement = mainPlayer2:AddToggle("AutoAchievements", {
	Title = "Auto Collect Achievements",
	Default = false,
	Callback = function(state)
		scriptSettings.PlayerTab.AutoAchievements = state
	end,
})

local autoChest = mainPlayer2:AddToggle("AutoChests", {
	Title = "Auto Collect Chest",
	Default = false,
	Callback = function(state)
		scriptSettings.PlayerTab.AutoChests = state
	end,
})

-- GACHA
local mainGacha = Tabs.Gachas:AddSection("Main")
mainGacha:AddParagraph({
	Title = "Gacha Features",
	Content = "\nHere you can find various features related to gacha mechanics.",
})

local selectGacha = mainGacha:AddDropdown("selectGacha", {
	Title = "Select Gacha",
	Description = "Select a gacha to spin",
	Values = Gachas,
	Multi = false,
	Default = "Psychic Power",
})

local selectGachaTarget = mainGacha:AddDropdown("selectGachaTarget", {
	Title = "Select Target",
	Description = "Select your target for spin",
	Values = Targets,
	Multi = true,
	Default = { "Choose a target" },
})

local autoGacha = mainGacha:AddToggle("autoGacha", {
	Title = "Auto Gacha",
	Default = false,
	Callback = function(state)
		scriptSettings.GachaTab.AutoGacha = state
	end,
})

local gachaSettings = Tabs.Gachas:AddSection("Settings")

local gachaDelay = gachaSettings:AddSlider("gachaDelay", {
	Title = "Spin Delay",
	Description = "Set the delay between each spin (in seconds)",
	Default = 0.1,
	Min = 0.1,
	Max = 5,
	Rounding = 0.1,
	Callback = function(Value)
		scriptSettings.GachaTab.GachaDelay = Value
	end,
})

local removeGachaAnim = gachaSettings:AddButton({
	Title = "Remove Gacha Animation",
	Callback = function()
		removeGachaAnimation()
	end,
})

-- GAMEMODE
local mainGamemode = Tabs.Gamemode:AddSection("Main")
mainGamemode:AddParagraph({
	Title = "Gamemode Features",
	Content = "\nHere you can find various features related to gamemodes.",
})

local selectGamemode = mainGamemode:AddDropdown("selectGamemode", {
	Title = "Select Gamemode",
	Description = "Select a gamemode to play",
	Values = Gamemodes,
	Multi = true,
	Default = { "Choose a gamemode" },
})

local autoFarmGamemodeMobs = mainGamemode:AddToggle("AutoFarmMobs", {
	Title = "Auto Farm Mobs",
	Default = false,
	Callback = function(state)
		scriptSettings.GamemodesTab.AutoFarmMobs = state
	end,
})

local mapsGamemode = Tabs.Gamemode:AddSection("Maps")

local selectRaid = mapsGamemode:AddDropdown("selectRaid", {
	Title = "Select Raid",
	Description = "Select an raid map",
	Values = RaidData,
	Multi = false,
	Default = "Choose an raid map",
})

local selectDungeon = mapsGamemode:AddDropdown("selectDungeon", {
	Title = "Select Dungeon",
	Description = "Select an dungeon map",
	Values = DungeonData,
	Multi = false,
	Default = "Choose an dungeon map",
})

local selectInfinity = mapsGamemode:AddDropdown("selectInfinity", {
	Title = "Select Infinity",
	Description = "Select an infinity map",
	Values = InfinityData,
	Multi = false,
	Default = "Choose an infinity map",
})

local diffGamemode = Tabs.Gamemode:AddSection("Difficulties")

local selectRaidDiff = diffGamemode:AddDropdown("selectRaidDiff", {
	Title = "Select Raid Diff",
	Description = "Select a difficulty for raids",
	Values = { "Easy", "Medium", "Hard" },
	Multi = false,
	Default = "",
})

local selectDungeonDiff = diffGamemode:AddDropdown("selectDungeonDiff", {
	Title = "Select Dungeon Diff",
	Description = "Select a difficulty for dungeons",
	Values = { "Easy", "Medium", "Hard" },
	Multi = false,
	Default = "",
})

local selectInfinityDiff = diffGamemode:AddDropdown("selectInfinityDiff", {
	Title = "Select Infinity Diff",
	Description = "Select a difficulty for infinity castle",
	Values = { "Easy" },
	Multi = false,
	Default = "",
})

local leaveGamemode = Tabs.Gamemode:AddSection("Leave in")

local raidLeaveIn = leaveGamemode:AddInput("raidLeaveIn", {
	Title = "Raid Leave In",
	Default = 0,
	Placeholder = "e.g 30",
	Numeric = true,
	Finished = true,
	Callback = function(Value)
		scriptSettings.GamemodesTab.RaidToLeave = Value
	end,
})

local dungeonLeaveIn = leaveGamemode:AddInput("dungeonLeaveIn", {
	Title = "Dungeon Leave In",
	Default = 0,
	Placeholder = "e.g 30",
	Numeric = true,
	Finished = true,
	Callback = function(Value)
		scriptSettings.GamemodesTab.DungeonToLeave = Value
	end,
})

local infinityLeaveIn = leaveGamemode:AddInput("infinityLeaveIn", {
	Title = "Infinity Leave In",
	Default = 0,
	Placeholder = "e.g 30",
	Numeric = true,
	Finished = true,
	Callback = function(Value)
		scriptSettings.GamemodesTab.InfinityCastleToLeave = Value
	end,
})

local autoLeaves = leaveGamemode:AddToggle("autoLeave", {
	Title = "Auto Leave Gamemode",
	Default = false,
	Callback = function(state)
		scriptSettings.GamemodesTab.AutoLeaveGamemode = state
	end,
})

local playerGamemode = Tabs.Gamemode:AddSection("Settings")

playerGamemode:AddParagraph({
	Title = "Status",
	Content = "StatusMode",
})

local saveWorldToTp = playerGamemode:AddDropdown("WorldToTp", {
	Title = "World To Teleport",
	Description = "Select a world to back",
	Values = MapsNum,
	Multi = false,
	Default = "",
})

local savePos = playerGamemode:AddButton({
	Title = "Save Position",
	Callback = function()
		savePlayerPosition()

		Fluent:Notify({
			Title = "Saved Position!",
			Content = "Position: " .. tostring(scriptSettings.GamemodesTab.SavedPosition) .. " | World: " .. tostring(
				scriptSettings.GamemodesTab.WorldToTeleport
			),
			Duration = 2,
		})
	end,

	changeDescription("PlayerStatus"),
})

local autoCreateGamemod = playerGamemode:AddToggle("AutoCreateGamemode", {
	Title = "Auto Create Gamemode",
	Default = false,
	Callback = function(state)
		scriptSettings.GamemodesTab.AutoCreateGamemode = state
	end,
})

local playerGamemode2 = Tabs.Gamemode:AddSection("")

local selectPlayersToJoin = playerGamemode2:AddDropdown("selectPlayersToJoin", {
	Title = "Select Player's Party to Join",
	Description = "Select players to join the gamemode",
	Values = PlayersInGamemodes,
	Multi = true,
	Default = {},
})

local refreshPlayers = playerGamemode2:AddButton({
	Title = "Refresh Players List",
	Callback = function()
		refreshPlayersList(selectPlayersToJoin)
	end,
})

local autoJoinSelected = playerGamemode2:AddToggle("autoJoinSelected", {
	Title = "Auto Join Gamemode (Selected Players)",
	Default = false,
	Callback = function(state)
		scriptSettings.GamemodesTab.AutoJoinSelectedGamemode = state
	end,
})

local autoJoinPublic = playerGamemode2:AddToggle("autoJoinPublic", {
	Title = "Auto Join Gamemode (Public)",
	Default = false,
	Callback = function(state)
		scriptSettings.GamemodesTab.AutoJoinPublicGamemode = state
	end,
})

-- Spawn functions
selectGacha:OnChanged(function(Value)
	table.clear(Targets)
	scriptSettings.GachaTab.SelectedGacha = Value

	for targetId in pairs(GachaData[Value].Targets) do
		if not table.find(Targets, targetId) then
			table.insert(Targets, targetId)
		end
	end

	selectGachaTarget:SetValue(Targets)
end)

selectGachaTarget:OnChanged(function(Value)
	scriptSettings.GachaTab.SelectedTarget = Value
end)

selectGamemode:OnChanged(function(Value)
	scriptSettings.GamemodesTab.SelectedGamemode = Value
end)

-- Diffs

selectInfinityDiff:OnChanged(function(Value)
	scriptSettings.GamemodesTab.SelectedInfinityCastleDifficulty = Value
end)

selectRaidDiff:OnChanged(function(Value)
	scriptSettings.GamemodesTab.SelectedRaidDifficulty = Value
end)

selectDungeonDiff:OnChanged(function(Value)
	scriptSettings.GamemodesTab.SelectedDungeonDifficulty = Value
end)

-- Maps

selectInfinity:OnChanged(function(Value)
	scriptSettings.GamemodesTab.SelectedInfinityCastle = Value
end)

selectRaid:OnChanged(function(Value)
	scriptSettings.GamemodesTab.SelectedRaid = Value
end)

selectDungeon:OnChanged(function(Value)
	scriptSettings.GamemodesTab.SelectedDungeon = Value
end)

selectPlayersToJoin:OnChanged(function(Value)
	scriptSettings.GamemodesTab.SelectedPlayersToJoin = Value
end)

saveWorldToTp:OnChanged(function(Value)
	scriptSettings.GamemodesTab.WorldToTeleport = Value
end)

task.spawn(function()
	while true do
		task.wait(scriptSettings.GachaTab.GachaDelay)

		if scriptSettings.GachaTab.AutoGacha and scriptSettings.GachaTab.SelectedGacha ~= "" then
			autoGachas(scriptSettings.GachaTab.SelectedGacha, scriptSettings.GachaTab.SelectedTarget)
		end

		if scriptSettings.GamemodesTab.AutoFarmMobs then
			autoFarmEnemies()
		end
	end
end)

task.spawn(function()
	local rewardTimer = 0

	while true do
		local dt = task.wait()

		if scriptSettings.PlayerTab.AutoClick then
			autoClickAnimation:SetValue(false)
			autoClicker()
		end

		if scriptSettings.PlayerTab.AutoClickAnimation then
			autoClick:SetValue(false)
			autoClickerWithAnimation()
		end

		if scriptSettings.GamemodesTab.AutoJoinPublicGamemode then
			autoJoinGamemode(gamemodeFold, "Public")
		end

		if scriptSettings.GamemodesTab.AutoJoinSelectedGamemode then
			autoJoinGamemode(gamemodeFold, "Private")
		end

		if scriptSettings.GamemodesTab.AutoLeaveGamemode then
			autoLeaveGamemode()
		end

		gamemodeNotifier()

		rewardTimer += dt
		if rewardTimer >= 1 then
			rewardTimer = 0
			if scriptSettings.GamemodesTab.AutoCreateGamemode then
				autoCreateGamemodes()
			end

			if scriptSettings.PlayerTab.AutoRewards then
				autoRewards()
			end

			if scriptSettings.PlayerTab.AutoAscension then
				autoAscension()
			end

			if scriptSettings.PlayerTab.AutoAchievements then
				autoAchievements()
			end

			if scriptSettings.PlayerTab.AutoChests then
				autoChests()
			end
			changeDescription("Ascension")
			changeDescription("PlayerStatus")
		end
	end
end)
