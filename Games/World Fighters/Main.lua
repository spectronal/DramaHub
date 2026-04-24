local BASE_URL = "https://raw.githubusercontent.com/spectronal/DramaHub/refs/heads/main/Games/World%20Fighters/"

local function import(path)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. path))()
    end)
    if not ok then
        warn("Erro ao importar", path, "->", result)
        return nil
    end
    return result
end

-- Settings
local Shared = import("Settings/Shared.lua")
local Utils = import("Settings/Utils.lua")
local Settings = import("Settings/Settings.lua")

-- Systems
local AutoFarm = import("Systems/AutoFarm.lua")
local Player = import("Systems/Player.lua")

-- User Interface
local AutoFarmUserInterface = import("User%20Interface/AutoFarm.lua")
local PlayerUserInterface = import("User%20Interface/Player.lua")

-- Global Variables
local Settings = getgenv().Settings
local Utils = getgenv().Utils
local Shared = getgenv().Shared

local Player = getgenv().Player
local AutoFarm = getgenv().AutoFarm

local AutoFarmInterface = getgenv().UserInterface.AutoFarm
local PlayerInterface = getgenv().UserInterface.Player

-- Services
local ReplicatedStorage = Shared.Services.ReplicatedStorage
local CoreGui = Shared.Services.CoreGui
local Players = Shared.Services.Players
local LocalPlayer = Shared.Services.LocalPlayer
local GameName = Shared.Services.GameName

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

CoreGui:FindFirstChild("ScreenGui").Name = "DramaHub"
CoreGui:FindFirstChild("DramaHub").DisplayOrder = 9999
CoreGui:FindFirstChild("DramaHub").Parent = LocalPlayer.PlayerGui

Fluent:Notify({ Title = "Drama Hub | Developer Version", Content = "Loading...", Duration = 2 })

local Window = Fluent:CreateWindow({
	Title = GameName,
	SubTitle = "DramaHub",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = false,
	Theme = "Darker",
	MinimizeKey = Enum.KeyCode.LeftControl,
})

local Tabs = {
	About = Window:AddTab({ Title = "About", Icon = "clipboard" }),
	UpdateLogs = Window:AddTab({ Title = "Update Logs", Icon = "arrow-big-up" }),
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "bot" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

Window:SelectTab(1)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

AutoFarmInterface:Build(Tabs)
PlayerInterface:Build(Tabs)

task.spawn(function()
    while true do task.wait(0.01)
        if Settings.Player.AutoClick then
            Player:Attack()
        end

        if Settings.Player.AutoResetRewards then
            Player:ResetRewards()
        end

        if Settings.Player.AutoClaimAllAchievements then
            Player:ClaimAchievements()
        end

        if Settings.Farm.AutoFarm then
            AutoFarm:FarmMob()
        end
    end
end)
