local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local descL abel

local Framework = require(replicatedStorage.Framework.Library)
local Abbreviate = Framework:GetService("AbbreviateService")
local MultiplierService = Framework:GetService("MultiplierService")
local DebounceService = Framework:GetService("DebounceService")
local AnimationService = Framework:GetService("AnimationService")

local TimeRewardData = Framework:GetData("TimeRewardData")
local WeeklyRewardData = Framework:GetData("WeeklyRewardData")
local WeeklyRewardService = Framework:GetService("WeeklyRewardService")
local RebirthData = Framework:GetData("RebirthData")
local AchievementData = Framework:GetData("AchievementData")
local ChestData = Framework:GetData("ChestData")

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
