getgenv().UserInterface.Player = {}

local PlayerInterface = getgenv().UserInterface.Player

function PlayerInterface:Build(Tabs)
    local Settings = getgenv().Settings

    local Main = Tabs.Player:AddSection("Main")

    Main:AddToggle("AutoClick", {
        Title = "Auto Click",
        Default = false,
        Callback = function(state)
            Settings.Player.AutoClick = state
        end,
    })

    local Main2 = Tabs.Player:AddSection("")

    Main2:AddToggle("AutoResetRewards", {
        Title = "Auto Reset Rewards",
        Default = false,
        Callback = function(state)
            Settings.Player.AutoResetRewards = state
        end,
    })

    Main2:AddToggle("AutoClaimAllAchievements", {
        Title = "Auto Claim All Achievements",
        Default = false,
        Callback = function(state)
            Settings.Player.AutoClaimAllAchievements = state
        end,
    })

end