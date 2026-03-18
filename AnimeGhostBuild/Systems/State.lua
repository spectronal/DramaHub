<<<<<<< HEAD
=======
-- Systems/State.lua
-- Shared state, settings and data containers used across all modules
-- Loaded via: loadstring(game:HttpGet(URL))()

>>>>>>> a7c92498be86213c075e5800ff42019ea1fb1cb4
getgenv().DH = getgenv().DH or {}
getgenv().DH.State = {}

local State = getgenv().DH.State

local replicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Framework = require(replicatedStorage.Framework.Library)

<<<<<<< HEAD
-- Script Settings
=======
-- ════════════════════════════════════════
-- Script Settings
-- ════════════════════════════════════════
>>>>>>> a7c92498be86213c075e5800ff42019ea1fb1cb4

State.scriptSettings = {
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

<<<<<<< HEAD
-- Framework Data
=======
-- ════════════════════════════════════════
-- Framework Data
-- ════════════════════════════════════════
>>>>>>> a7c92498be86213c075e5800ff42019ea1fb1cb4

State.Framework = Framework
State.TimeRewardData = Framework:GetData("TimeRewardData")
State.WeeklyRewardData = Framework:GetData("WeeklyRewardData")
State.WeeklyRewardService = Framework:GetService("WeeklyRewardService")
State.RebirthData = Framework:GetData("RebirthData")
State.AchievementData = Framework:GetData("AchievementData")
State.ChestData = Framework:GetData("ChestData")
State.GachaData = Framework:GetData("GachaData")
State.GamemodeData = Framework:GetData("GamemodeData")
State.MapData = Framework:GetData("MapData")

<<<<<<< HEAD
-- Gacha State
=======
-- ════════════════════════════════════════
-- Gacha State
-- ════════════════════════════════════════
>>>>>>> a7c92498be86213c075e5800ff42019ea1fb1cb4

State.Gachas = {}
State.Targets = {}

for id in pairs(State.GachaData) do
	table.insert(State.Gachas, id)
end

<<<<<<< HEAD
-- Gamemode State
=======
-- ════════════════════════════════════════
-- Gamemode State
-- ════════════════════════════════════════
>>>>>>> a7c92498be86213c075e5800ff42019ea1fb1cb4

State.PlayersInGamemodes = {}
State.Gamemodes = {}

State.PriorityMap = {
	["Raid"] = 1,
	["Dungeon"] = 2,
	["Infinity Castle"] = 3,
}

State.cooldowns = {
	Raid = 0,
	Dungeon = 0,
	["Infinity Castle"] = 0,
}

State.MapsNum = {}
State.RaidData = {}
State.DungeonData = {}
State.InfinityData = {}

State.gamemodeFold = workspace:WaitForChild("_MAP"):WaitForChild("Gamemode")
State.gamemodeServer = replicatedStorage:WaitForChild("Server").Gamemode
State.lastCreate = 0

<<<<<<< HEAD
-- Auto Click State
=======
-- ════════════════════════════════════════
-- Auto Click State
-- ════════════════════════════════════════
>>>>>>> a7c92498be86213c075e5800ff42019ea1fb1cb4

State.lastClickTime = tick()
State.comboIndex = 0

<<<<<<< HEAD
-- Auto Farm State
=======
-- ════════════════════════════════════════
-- Auto Farm State
-- ════════════════════════════════════════
>>>>>>> a7c92498be86213c075e5800ff42019ea1fb1cb4

State.enemiesFolder = workspace["_ENEMIES"].Server
State.PlayerRootPart = workspace["_CHARACTERS"][LocalPlayer.Name].HumanoidRootPart
State.currentMob = nil
State.lastHP = nil
State.stuckTime = 0
State.lastTeleport = 0
State.teleportCooldown = 0.5

<<<<<<< HEAD
-- Description / UI State

State.Descriptions = {}

-- Gamemode Notifier State
=======
-- ════════════════════════════════════════
-- Description / UI State
-- ════════════════════════════════════════

State.Descriptions = {}

-- ════════════════════════════════════════
-- Gamemode Notifier State
-- ════════════════════════════════════════
>>>>>>> a7c92498be86213c075e5800ff42019ea1fb1cb4

State.lastInMode = false
State.lastMode = nil
