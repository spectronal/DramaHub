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
    TweenService = game:GetService("TweenService")
}