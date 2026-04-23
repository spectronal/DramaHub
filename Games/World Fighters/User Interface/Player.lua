getgenv().UserInterface = {}
getgenv().UserInterface.Player = {}

local PlayerInterface = getgenv().UserInterface.Player

function PlayerInterface:Build(Tabs)
    local ClickSystem = getgenv().Click
    local Settings = getgenv().Settings

    local Main = Tabs.Player:AddSection("Main")

    Main:AddToggle("AutoClick", {
        Title = "Auto Click",
        Default = false,
        Callback = function(state)
            Settings.AutoClick.Enabled = state
        end,
    })

    Main:AddToggle("AutoAwakening", {
        Title = "Auto Awakening",
        Default = false,
        Callback = function(state)
            Settings.AutoAwakening.Enabled = state
        end,
    })
end