getgenv().Player = {}
local Shared = getgenv().Shared
local Player = getgenv().Player

local Omni = Shared.Omni

function Player:Attack()
    local enemies = Omni.Cache:Get({ "EnemiesOnRangeIds" }) or {}
    Omni.Signal:Fire("General", "Attack", "Click", enemies)
end

function Player:ClaimAchievements()
    for _, category in Omni.Shared.Achievements.List do
        for _, achievement in category do

            local claimed = Omni.Data.Achievements[achievement.Name] == true

            local _,_, progress = Omni.Shared.Achievements.GetInformation(Omni.Data, achievement)

            if progress == 1 and not claimed then
                Omni.Signal:Fire("General", "Achievements", "ClaimAll")        
            end
        end
    end
end

function Player:CollectChests()
    local currentTime = workspace:GetServerTimeNow()

    for name, chestInfo in pairs(Omni.Shared.Chests) do
        local cooldown = chestInfo.Cooldown
        local lastClaim = Omni.Data.Chests[name] or 0

        local remaining = (lastClaim + cooldown) - currentTime
        local timeLeft = math.max(0, remaining)
        local rounded = math.round(timeLeft)
        
        if rounded <= 0 then
            Omni.Signal:Fire("General", "Chests", "Claim", name)
        end
    end
end

function Player:ResetRewards()
    local count = 0

    for i, v in pairs(Omni.Data.TimeRewards.Claimed) do
        count += 1
    end

    if count >= 7 then
        Omni.Signal:Fire("General", "TimeRewards", "Reset")
    end
end
