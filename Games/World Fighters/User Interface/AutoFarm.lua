getgenv().UserInterface = {} or {}
getgenv().UserInterface.AutoFarm = {}

local AutoFarmInterface = getgenv().UserInterface.AutoFarm
local Shared = getgenv().Shared
local Settings = getgenv().Settings
local Utils = getgenv().Utils

local Inserted = Shared.FarmConfig.Inserted

function AutoFarmInterface:Build(Tabs)

    local Main = Tabs.AutoFarm:AddSection("Enemy Configuration")

    local EnemiesDropdown = Main:AddDropdown("Select Enemies", {
        Title = "Select Enemies",
        Multi = true,
        Values = Utils.GetEnemies("Game"),
        Default = {},
        Callback = function(state)
            Settings.Farm.SelectedEnemy = state
        end,
    })

    local PriorityDropdown = Main:AddDropdown("Priority", {
        Title = "Priority",
        Values = {"Strongest > Weakest", "Weakest > Strongest"},
        Default = "Strongest > Weakest",
        Callback = function(state)
            Settings.Farm.Priority = state
        end,
    })

    Main:AddButton("Refresh Enemies", function()
        Utils.GetEnemies("Clear")
        EnemiesDropdown:SetValue(Utils.GetEnemies("Game"))
    end)

    Main:AddToggle("AutoFarm", {
        Title = "Auto Farm",
        Default = false,
        Callback = function(state)
            Settings.Farm.AutoFarm = state
        end,
    })

    EnemiesDropdown:OnChanged(function(Value)
        Settings.Farm.SelectedEnemy = Value
    end)

    PriorityDropdown:OnChanged(function(Value)
        Settings.Farm.Priority = Value
    end)
end