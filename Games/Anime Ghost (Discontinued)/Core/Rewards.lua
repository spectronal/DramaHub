getgenv().DH = getgenv().DH or {}
getgenv().DH.Rewards = {}

local Rewards = getgenv().DH.Rewards
local State = getgenv().DH.State

local Framework = State.Framework

-- Achievement Functions

local function GetCurrentTier(typeName)
	local completed = 0

	for id, _ in Framework.PlayerData.Achievements do
		if id:match(typeName) then
			completed += 1
		end
	end

	local nextTier = completed + 1

	if State.AchievementData[typeName .. nextTier] then
		return typeName .. nextTier, nextTier
	else
		return typeName .. completed, completed
	end
end

local function GetAchievementTypes()
	local types = {}

	for key, _ in State.AchievementData do
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
		local data = State.AchievementData[id]
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

-- Auto Rewards

function Rewards.autoRewards()
	local PlayerData = Framework.PlayerData

	for typeName, config in pairs(State.TimeRewardData) do
		local data = PlayerData.TimeRewards[typeName]

		if data then
			local time = data.Time

			for index, reward in pairs(config.Rewards) do
				if not data.Claimed[index] and reward.Time < time then
					Framework.Remote:Fire("TimeRewardSystem", "Claim", typeName, index)
				end
			end

			if time >= config.ResetTime then
				Framework.Remote:Fire("TimeRewardSystem", "Reset", typeName)
			end
		end
	end

	local currentDay = State.WeeklyRewardService.CurrentDay()

	for typeName, _ in pairs(State.WeeklyRewardData) do
		local playerData = Framework.PlayerData.WeeklyRewards[typeName]

		if playerData then
			if
				not playerData.Claimed[tostring(currentDay)]
				and State.WeeklyRewardService.HOUR_TIME <= playerData.Time
			then
				Framework.Remote:Fire("WeeklyRewardSystem", "Claim", typeName, currentDay)
			end
		end
	end
end

-- Auto Achievements

function Rewards.autoAchievements()
	for _, typeName in GetAchievementTypes() do
		local id = GetCurrentTier(typeName)

		if GetClaimableAchievements()[id] then
			Framework.Remote:Fire("AchievementSystem", "Claim", id)
		end
	end
end

-- Auto Chests

function Rewards.autoChests()
	for chestId, chestConfig in pairs(State.ChestData) do
		if chestConfig.CanClaim(Framework.LocalPlayer) then
			Framework.Remote:Fire("ChestSystem", "Claim", chestId)
		end
	end
end
