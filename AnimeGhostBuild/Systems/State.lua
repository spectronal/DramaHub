getgenv().DH = getgenv().DH or {}
getgenv().DH.State = {}

local State = getgenv().DH.State

local replicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Framework = require(replicatedStorage.Framework.Library)
-- Script Settings

State.scriptSettings = {
	FarmTab = {
		SelectedMobs = { "" },
		AutoFarm = false,
		AutoFarmWithScroll = false,
	},
	ScrollsTab = {
		SelectedScroll = "",

		AutoOpenScroll = false,
		TeleportToEgg = false,
	},
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
		SelectedDefenseMode = "",

		SelectedRaidDifficulty = "",
		SelectedDungeonDifficulty = "",
		SelectedInfinityCastleDifficulty = "",
		SelectedDefenseModeDifficulty = "",

		SelectedPlayersToJoin = { "" },

		RaidToLeave = 0,
		DungeonToLeave = 0,
		InfinityCastleToLeave = 0,
		DefenseToLeave = 0,

		SelectedEquipBestInMode = "Energy",
		SelectedEquipBestNoMode = "Energy",
		SelectedEquipTitleInMode = "",
		SelectedEquipTitleNoMode = "",

		AutoJoinPublicGamemode = false,
		AutoJoinSelectedGamemode = false,
		AutoCreateGamemode = false,
		AutoLeaveGamemode = false,
		AutoFarmMobs = false,
		AutoEquipBest = false,
		WorldToTeleport = 0,
		SavedPosition = nil,
	},
	Roles = {
		["DRAMAHUB DEVELOPER"] = Color3.new(1, 0, 0),
		["DRAMAHUB PREMIUM"] = Color3.new(1, 0.682353, 0),
		["DRAMAHUB USER"] = Color3.new(0, 0.882353, 1),
	},
}

State.Framework = Framework

-- Framework Services/Packages
State.GuiService = Framework:GetService("GuiService")
State.Janitor = Framework:GetPackage("Janitor")

-- Framework Data

State.TimeRewardData = Framework:GetData("TimeRewardData")
State.WeeklyRewardData = Framework:GetData("WeeklyRewardData")
State.WeeklyRewardService = Framework:GetService("WeeklyRewardService")
State.RebirthData = Framework:GetData("RebirthData")
State.AchievementData = Framework:GetData("AchievementData")
State.ChestData = Framework:GetData("ChestData")
State.GachaData = Framework:GetData("GachaData")
State.GamemodeData = Framework:GetData("GamemodeData")
State.MapData = Framework:GetData("MapData")
State.TitleData = Framework:GetData("TitleData")

-- Gacha State

State.Gachas = {}
State.Targets = {}

for id in pairs(State.GachaData) do
	table.insert(State.Gachas, id)
end

-- Scrolls State
State.mapScrolls = {}

-- Gamemode State

State.PlayersInGamemodes = {}
State.Gamemodes = {}

State.PriorityMap = {
	["Raid"] = 1,
	["Dungeon"] = 2,
	["Infinity Castle"] = 3,
	["Defense Mode"] = 4,
}

State.cooldowns = {
	Raid = 0,
	Dungeon = 0,
	["Infinity Castle"] = 0,
	["Defense Mode"] = 0,
}

State.MapsNum = {}
State.RaidData = {}
State.DungeonData = {}
State.InfinityData = {}
State.DefenseData = {}

State.gamemodeFold = workspace:WaitForChild("_MAP"):WaitForChild("Gamemode")
State.gamemodeServer = replicatedStorage:WaitForChild("Server").Gamemode
State.lastCreate = 0

State.Titles = {}

-- Auto Click State

State.lastClickTime = tick()
State.comboIndex = 0

-- Auto Farm State
State.Inserted = {}
State.Mobs = {}
State.enemiesFolder = workspace["_ENEMIES"].Server
State.enemiesClientFolder = State.enemiesFolder.Parent.Client
State.PlayerRootPart = workspace["_CHARACTERS"][LocalPlayer.Name].HumanoidRootPart
State.currentMob = nil
State.lastHP = nil
State.stuckTime = 0
State.lastTeleport = 0
State.teleportCooldown = 0.2

-- Description / UI State

State.Descriptions = {}

-- Gamemode Notifier State

State.lastInMode = false
State.lastMode = nil
