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

local Shared = import("Settings/Shared.lua")
local Utils = import("Settings/Utils.lua")
local Settings = import("Settings/Settings.lua")
local Click = import("Systems/Click.lua")

local Settings = getgenv().Settings
local Utils = getgenv().Utils
local Shared = getgenv().Shared

local ReplicatedStorage = Utils.Services.ReplicatedStorage
local CoreGui = Utils.Services.CoreGui
local Players = Utils.Services.Players
local LocalPlayer = Utils.Services.LocalPlayer
local GameName = Utils.Services.GameName

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
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

Window:SelectTab(1)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

task.spawn(function()
    while true do
        if Settings.AutoClick.Enabled then
            Click.Attack()
        end
        task.wait(Settings.AutoClick.Delay)
    end
end)
