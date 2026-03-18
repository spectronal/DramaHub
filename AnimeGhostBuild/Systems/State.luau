return function()
	return {
		Settings = {
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
				SelectedTarget = {},
				GachaDelay = 0.1,
				AutoGacha = false,
			},
			GamemodesTab = {
				SelectedGamemode = {
					["Raid"] = false,
					["Dungeon"] = false,
					["Infinity Castle"] = false,
				},
				SelectedRaid = "",
				SelectedDungeon = "",
				SelectedInfinityCastle = "",
				SelectedRaidDifficulty = "",
				SelectedDungeonDifficulty = "",
				SelectedInfinityCastleDifficulty = "",
				SelectedPlayersToJoin = {},
				RaidToLeave = 0,
				DungeonToLeave = 0,
				InfinityCastleToLeave = 0,
				AutoJoinPublicGamemode = false,
				AutoJoinSelectedGamemode = false,
				AutoCreateGamemode = false,
				AutoLeaveGamemode = false,
				AutoFarmMobs = false,
			},
		},

		Cooldowns = {
			Raid = 0,
			Dungeon = 0,
			["Infinity Castle"] = 0,
		},

		Runtime = {
			currentMob = nil,
			lastHP = nil,
			stuckTime = 0,
			lastTeleport = 0,
		},
	}
end
