getgenv().DH = getgenv().DH or {}
getgenv().DH.Gamemode = {}

local Gamemode = getgenv().DH.Gamemode
local State = getgenv().DH.State

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Framework = State.Framework
local Notifier = Framework:GetService("NotifyService")

local Janitor = State.Janitor
local GuiService = State.GuiService
local newJanitor = Janitor.new()

local Inserted = State.Inserted
local alreadyLeft = false

-- Setup

function Gamemode.setupGamemodeData()
	local Utils = getgenv().DH.Utils
	local RoleLabel = workspace._CHARACTERS[LocalPlayer.Name].GUI.Role

	for role, color in pairs(State.scriptSettings.Roles) do
		if DRAMAHUB_VERSION == "DEVELOPMENT BUILD" then
			if LocalPlayer.UserId == AUTHOR then
				if role == "DRAMAHUB DEVELOPER" then
					RoleLabel.Text = string.format("<font color='#%s'>[%s]</font>", Utils.Color3ToHex(color), role)
				end
			else
				RoleLabel.Text = string.format("<font color='#%s'>[%s]</font>", Utils.Color3ToHex(color), role)
			end
		end
	end

	for id in pairs(State.GamemodeData) do
		table.insert(State.Gamemodes, id)
	end

	for _, names in pairs(Players:GetPlayers()) do
		table.insert(State.PlayersInGamemodes, names.Name)
	end

	for raids, _ in pairs(State.GamemodeData["Raid"]) do
		table.insert(State.RaidData, raids)
	end

	for dungeons, _ in pairs(State.GamemodeData["Dungeon"]) do
		table.insert(State.DungeonData, dungeons)
	end

	for infinity, _ in pairs(State.GamemodeData["Infinity Castle"]) do
		table.insert(State.InfinityData, infinity)
	end

	for defense, _ in pairs(State.GamemodeData["Defense Mode"]) do
		table.insert(State.DefenseData, defense)
	end

	for maps, _ in State.MapData do
		table.insert(State.MapsNum, maps)
	end

	for i, v in pairs(State.MapData) do
		table.insert(State.mapScrolls, v["EggName"])
	end

	for titles, v in pairs(State.Framework.PlayerData.Titles) do
		table.insert(State.Titles, titles)
	end

	for potions, _ in pairs(State.Framework.PlayerData.Inventory) do
		if potions:match("Potion") then
			table.insert(State.Potions, potions)
		end
	end

	for _, mob in pairs(State.enemiesFolder:GetDescendants()) do
		if mob:IsA("Part") and mob:GetAttribute("HP") then
			for _, mobClient in pairs(State.enemiesClientFolder:GetChildren()) do
				if mobClient:IsA("Model") then
					if mob.Name == mobClient.Name then
						local mobName = mob:GetAttribute("Name")

						if not Inserted[mobName] then
							Inserted[mobName] = true
							table.insert(State.Mobs, mobName)
						end
					end
				end
			end
		end
	end
end

-- Cooldown Listener

for mode, time in pairs(Framework.PlayerData.Delay) do
	if State.cooldowns[mode] then
		State.cooldowns[mode] = time - os.time()
	end
end

-- Cooldown Helpers

local function isOnCooldown(mode)
	local remaining = State.cooldowns[mode] - tick()
	if remaining > 0 then
	end
	return remaining > 0.5
end

local function getCooldownRemaining(mode)
	if not State.cooldowns[mode] then
		return 0
	end
	return math.max(0, State.cooldowns[mode] - tick())
end

local function formatTime(t)
	if t <= 0 then
		return "Ready"
	end
	local m = math.floor(t / 60)
	local s = math.floor(t % 60)
	return string.format("%d:%02d", m, s)
end

-- Ui Handler
local function enableUI()
	task.wait(1.2)
	LocalPlayer:WaitForChild("PlayerGui").Results.Content.Visible = false
	GuiService.SetScreens(true, { "SideGUI", "Utils" }, true)
	newJanitor:Cleanup()
end

-- Mode Queries

function Gamemode.inMode()
	local modeName = LocalPlayer:GetAttribute("InMode")
	if not modeName then
		return false
	end

	local mode = State.gamemodeServer:FindFirstChild(modeName)
	if not mode then
		return false
	end

	local playersFolder = mode:FindFirstChild("Players")
	if not playersFolder then
		return false
	end

	return playersFolder:GetAttribute(tostring(LocalPlayer.UserId)) ~= nil
end

function Gamemode.getPlayerMode(typeMode)
	for _, mode in pairs(State.gamemodeServer:GetChildren()) do
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

-- Cooldown Text

function Gamemode.getCooldownsText()
	local parts = {}

	for mode, _ in pairs(State.cooldowns) do
		local remaining = getCooldownRemaining(mode)
		table.insert(parts, `{mode} : {formatTime(remaining)}`)
	end

	return table.concat(parts, "\n")
end

-- Join / Create / Leave

function Gamemode.autoJoinGamemode(gamemode, select)
	if Gamemode.inMode() then
		return
	end

	if select == "Private" then
		for playerName, _ in pairs(State.scriptSettings.GamemodesTab.SelectedPlayersToJoin) do
			if not Players[playerName] then
				return
			end

			local player = Players[playerName] or nil
			if player:GetAttribute("Mode") then
				local modeText = player:GetAttribute("Mode")
				if State.scriptSettings.GamemodesTab.SelectedGamemode[modeText] then
					Framework.Remote:Fire("GamemodeSystem", "Join", modeText, player.UserId)
				end
			end
		end
	elseif select == "Public" then
		for _, playerObj in pairs(Players:GetPlayers()) do
			if not Players[playerObj.Name] then
				return
			end

			local player = Players[playerObj.Name]
			if player:GetAttribute("Mode") then
				local modeText = player:GetAttribute("Mode")
				if State.scriptSettings.GamemodesTab.SelectedGamemode[modeText] then
					Framework.Remote:Fire("GamemodeSystem", "Join", modeText, player.UserId)
				end
			end
		end
	end
end

function Gamemode.autoCreateGamemodes()
	if Gamemode.inMode() then
		return
	end

	if tick() - State.lastCreate < 2 then
		return
	end
	State.lastCreate = tick()

	local chosen = nil
	local bestPriority = math.huge

	for gamemode, enabled in pairs(State.scriptSettings.GamemodesTab.SelectedGamemode) do
		if enabled then
			local priority = State.PriorityMap[gamemode]

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
		State.scriptSettings.GamemodesTab[key],
		State.scriptSettings.GamemodesTab[difficulty]
	)

	task.wait(1)

	Framework.Remote:Fire("GamemodeSystem", "Start", Gamemode.getPlayerMode("ModeId"), LocalPlayer.UserId)
end

function Gamemode.autoLeaveGamemode()
	if State.scriptSettings.GamemodesTab.SavedPosition ~= nil then
		if not Gamemode.inMode() then
			if alreadyLeft then
				return
			end
			alreadyLeft = true

			Gamemode.teleportPlayerToPosition()
			return
		end

		alreadyLeft = false

		local modeName = Gamemode.getPlayerMode("Mode")
		if not modeName then
			return
		end

		local mode = State.gamemodeServer:FindFirstChild(modeName)
		if not mode then
			return
		end

		local Wave = tonumber(mode:GetAttribute("Stage")) or 0
		local CurrentMode = string.gsub(mode:GetAttribute("ModeId") or "", " ", "")
		local MaxWave = tonumber(State.scriptSettings.GamemodesTab[CurrentMode .. "ToLeave"]) or 0

		if MaxWave ~= 0 and Wave >= MaxWave then
			alreadyLeft = true
			Gamemode.teleportPlayerToPosition()
		end
	end
end

-- Position Save / Return

function Gamemode.savePlayerPosition()
	local RootPart = workspace["_CHARACTERS"][LocalPlayer.Name].HumanoidRootPart
	State.scriptSettings.GamemodesTab.SavedPosition = RootPart.Position
end

function Gamemode.teleportPlayerToPosition()
	local RootPart = workspace["_CHARACTERS"][LocalPlayer.Name].HumanoidRootPart
	Framework.Remote:Fire("TeleportSystem", "To", State.scriptSettings.GamemodesTab.WorldToTeleport)
	task.wait(3)
	enableUI()
	RootPart.CFrame = CFrame.new(State.scriptSettings.GamemodesTab.SavedPosition)
end

-- Equip Best Mode/NoMode

function Gamemode.EquipBest()
	if LocalPlayer:GetAttribute("InMode") then
		if LocalPlayer:GetAttribute("EquipBest") == State.scriptSettings.GamemodesTab.SelectedEquipBestInMode then
			return
		end

		Framework.Remote:Fire("EquipBestSystem", "Apply", State.scriptSettings.GamemodesTab.SelectedEquipBestInMode)
		Notifier(
			"<dr> [Drama Hub] </>"
				.. "<w> All "
				.. State.scriptSettings.GamemodesTab.SelectedEquipBestInMode
				.. " buffs equippeds in Gamemode! </>"
		)

		LocalPlayer:SetAttribute("EquipBest", State.scriptSettings.GamemodesTab.SelectedEquipBestInMode)
	else
		if LocalPlayer:GetAttribute("EquipBest") == State.scriptSettings.GamemodesTab.SelectedEquipBestNoMode then
			return
		end

		Framework.Remote:Fire("EquipBestSystem", "Apply", State.scriptSettings.GamemodesTab.SelectedEquipBestNoMode)
		Notifier(
			"<dr> [Drama Hub] </>"
				.. "<w> All "
				.. State.scriptSettings.GamemodesTab.SelectedEquipBestNoMode
				.. " buffs equippeds! </>"
		)

		LocalPlayer:SetAttribute("EquipBest", State.scriptSettings.GamemodesTab.SelectedEquipBestNoMode)
	end
end

function Gamemode.EquipTitle()
	if LocalPlayer:GetAttribute("InMode") then
		if State.Framework.PlayerData.TitleBoost == State.scriptSettings.GamemodesTab.SelectedEquipTitleInMode then
			return
		end

		Framework.Remote:Fire(
			"TitleSystem",
			"Equip",
			"Boost",
			State.scriptSettings.GamemodesTab.SelectedEquipTitleInMode
		)
		Notifier(
			"<dr> [Drama Hub] </>"
				.. "<w> Title: "
				.. State.scriptSettings.GamemodesTab.SelectedEquipTitleInMode
				.. " equipped! </>"
		)
	else
		if State.Framework.PlayerData.TitleBoost == State.scriptSettings.GamemodesTab.SelectedEquipTitleNoMode then
			return
		end

		Framework.Remote:Fire(
			"TitleSystem",
			"Equip",
			"Boost",
			State.scriptSettings.GamemodesTab.SelectedEquipTitleNoMode
		)
		Notifier(
			"<dr> [Drama Hub] </>"
				.. "<w> Title: "
				.. State.scriptSettings.GamemodesTab.SelectedEquipTitleNoMode
				.. " equipped! </>"
		)
	end
end

-- Notifier

function Gamemode.gamemodeNotifier(Fluent)
	local isIn = Gamemode.inMode()
	local mode = Gamemode.getPlayerMode("ModeId")

	if State.lastInMode and not isIn then
		Fluent:Notify({
			Title = "Gamemode System",
			Content = "You left the gamemode",
			Duration = 2,
		})
	end

	if not State.lastInMode and isIn then
		local ownerName = "Unknown"
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

	State.lastInMode = isIn
	State.lastMode = mode
end

-- Description: PlayerStatus

function Gamemode.changeDescriptionPlayerStatus(setDescription)
	setDescription(
		"PlayerStatus",
		`Priority: Raid > Dungeon > Infinity Castle > Defense Mode\n \nModes: \n{Gamemode.getCooldownsText()} \n \nSaved Position: World: {(tostring(
			State.scriptSettings.GamemodesTab.WorldToTeleport
		) or "Nil")} / {tostring(State.scriptSettings.GamemodesTab.SavedPosition)}`
	)
end
