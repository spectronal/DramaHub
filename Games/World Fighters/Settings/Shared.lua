local HttpService = game:GetService("HttpService")

local Omni = require(game:GetService("ReplicatedStorage"):WaitForChild("Omni"))

getgenv().Shared = {}

local Shared = getgenv().Shared

Shared.Omni = Omni

Shared.Services = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players"),
    PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"),
    MarketplaceService = game:GetService("MarketplaceService"),
    LocalPlayer = game:GetService("Players").LocalPlayer,
    GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService")
}

Shared.Utils = {
    HumanoidRootPart = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or nil,
    Humanoid = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") or nil,
}

Shared.FarmConfig = {
    Inserted = {},
    Enemies = {},
    lastTeleport = 0,
    teleportCooldown = 0.2,
    stuckTime = 0,
    currentMobGamemode = nil,
    currentMobNormal = nil,
    lastHP = nil,
}